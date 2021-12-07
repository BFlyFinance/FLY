// Copyright (c) The Elements Studio Core Contributors
// SPDX-License-Identifier: Apache-2.0

// TODO: replace the address with admin address
address 0x3db7a2da7444995338a2413b151ee437 {

/// Token Swap
module TokenSwap {
    use 0x1::Token;
    use 0x1::Signer;
    use 0x1::Compare;
    use 0x1::BCS;
    use 0x1::Timestamp;
    use 0x1::Event;
    use 0x3db7a2da7444995338a2413b151ee437::SafeMath;

    struct LiquidityToken<X, Y> has key, store { }

    struct LiquidityTokenCapability<X, Y> has key, store {
        mint: Token::MintCapability<LiquidityToken<X, Y>>,
        burn: Token::BurnCapability<LiquidityToken<X, Y>>,
    }

    /// Event emitted when add token liquidity.
    struct AddLiquidityEvent has drop, store {
        /// liquidity value by user X and Y type
        liquidity: u128,
        /// token code of X type
        x_token_code: Token::TokenCode,
        /// token code of X type
        y_token_code: Token::TokenCode,
        /// signer of add liquidity
        signer: address,
        amount_x_desired: u128,
        amount_y_desired: u128,
        amount_x_min: u128,
        amount_y_min: u128,
    }

    /// Event emitted when remove token liquidity.
    struct RemoveLiquidityEvent has drop, store {
        /// liquidity value by user X and Y type
        liquidity: u128,
        /// token code of X type
        x_token_code: Token::TokenCode,
        /// token code of X type
        y_token_code: Token::TokenCode,
        /// signer of remove liquidity
        signer: address,
        amount_x_min: u128,
        amount_y_min: u128,
    }

    /// Event emitted when token swap.
    struct SwapEvent has drop, store {
        /// token code of X type
        x_token_code: Token::TokenCode,
        /// token code of X type
        y_token_code: Token::TokenCode,
        x_in: u128,
        y_out: u128,
        signer: address,
    }

    /// Event emitted when token swap .
    struct SwapFeeEvent has drop, store {
        /// token code of X type
        x_token_code: Token::TokenCode,
        /// token code of X type
        y_token_code: Token::TokenCode,
        signer: address,
        fee_addree: address,
        swap_fee: u128,
        fee_out: u128,
    }


    struct TokenPair<X, Y> has key, store  {
        token_x_reserve: Token::Token<X>,
        token_y_reserve: Token::Token<Y>,
        last_block_timestamp: u64,
        last_price_x_cumulative: u128,
        last_price_y_cumulative: u128,
        last_k: u128,
        add_liquidity_event: Event::EventHandle<AddLiquidityEvent>,
        remove_liquidity_event: Event::EventHandle<RemoveLiquidityEvent>,
        swap_event: Event::EventHandle<SwapEvent>,
        swap_fee_event: Event::EventHandle<SwapFeeEvent>,
    }

    const ERROR_SWAP_INVALID_TOKEN_PAIR: u64 = 2000;
    const ERROR_SWAP_INVALID_PARAMETER: u64 = 2001;
    const ERROR_SWAP_TOKEN_INSUFFICIENT: u64 = 2002;
    const ERROR_SWAP_DUPLICATE_TOKEN: u64 = 2003;
    const ERROR_SWAP_BURN_CALC_INVALID: u64 = 2004;
    const ERROR_SWAP_SWAPOUT_CALC_INVALID: u64 = 2005;
    const ERROR_SWAP_PRIVILEGE_INSUFFICIENT: u64 = 2006;
    const ERROR_SWAP_ADDLIQUIDITY_INVALID: u64 = 2007;
    const ERROR_SWAP_TOKEN_NOT_EXISTS: u64 = 2008;
    const ERROR_SWAP_TOKEN_FEE_INVALID: u64 = 2009;

    const SWAP_FEE_SWITCH_ON: bool= true;
    const SWAP_FEE_SWITCH_OFF: bool= false;

    const EQUAL: u8 = 0;
    const LESS_THAN: u8 = 1;
    const GREATER_THAN: u8 = 2;

    /// Check if swap pair exists
    public fun swap_pair_exists<X: store, Y: store>() : bool {
        let order = compare_token<X, Y>();
        assert(order != 0, ERROR_SWAP_INVALID_TOKEN_PAIR);
        Token::is_registered_in<LiquidityToken<X, Y>>(admin_address())
    }

    // for now, only admin can register token pair
    public fun register_swap_pair<X: store, Y: store>(signer: &signer) {
        // check X,Y is token.
        assert_is_token<X>();
        assert_is_token<Y>();

        let order = compare_token<X, Y>();
        assert(order != 0, ERROR_SWAP_INVALID_TOKEN_PAIR);
        assert_admin(signer);
        let token_pair = make_token_pair<X, Y>(signer);
        move_to(signer, token_pair);
        register_liquidity_token<X, Y>(signer);
    }

    fun register_liquidity_token<X: store, Y: store>(signer: &signer) {
        assert_admin(signer);
        Token::register_token<LiquidityToken<X, Y>>(signer, 18);
        let mint_capability = Token::remove_mint_capability<LiquidityToken<X, Y>>(signer);
        let burn_capability = Token::remove_burn_capability<LiquidityToken<X, Y>>(signer);
        move_to(signer, LiquidityTokenCapability { mint: mint_capability, burn: burn_capability });
    }

    fun make_token_pair<X: store, Y: store>(signer: &signer): TokenPair<X, Y> {
        TokenPair<X, Y> {
            token_x_reserve: Token::zero<X>(),
            token_y_reserve: Token::zero<Y>(),
            last_block_timestamp: 0,
            last_price_x_cumulative: 0,
            last_price_y_cumulative: 0,
            last_k: 0,
            add_liquidity_event: Event::new_event_handle<AddLiquidityEvent>(signer),
            remove_liquidity_event: Event::new_event_handle<RemoveLiquidityEvent>(signer),
            swap_event: Event::new_event_handle<SwapEvent>(signer),
            swap_fee_event: Event::new_event_handle<SwapFeeEvent>(signer),
        }
    }

    /// Liquidity Provider's methods
    /// type args, X, Y should be sorted.
    public fun mint<X: store, Y: store>(
        x: Token::Token<X>,
        y: Token::Token<Y>,
    ): Token::Token<LiquidityToken<X, Y>> acquires TokenPair, LiquidityTokenCapability {
        let total_supply: u128 = Token::market_cap<LiquidityToken<X, Y>>();
        let (x_reserve, y_reserve) = get_reserves<X, Y>();
        let x_value = Token::value<X>(&x);
        let y_value = Token::value<Y>(&y);
        let liquidity = if (total_supply == 0) {
            // 1000 is the MINIMUM_LIQUIDITY
            // sqrt(x*y) - 1000
            SafeMath::sqrt_u256(SafeMath::mul_u256(x_value, y_value)) - 1000
        } else {
            let x_liquidity = SafeMath::safe_mul_div(x_value, total_supply, x_reserve);
            let y_liquidity = SafeMath::safe_mul_div(y_value, total_supply, y_reserve);
            // use smaller one.
            if (x_liquidity < y_liquidity) {
                x_liquidity
            } else {
                y_liquidity
            }
        };
        assert(liquidity > 0, ERROR_SWAP_ADDLIQUIDITY_INVALID);
        let token_pair = borrow_global_mut<TokenPair<X, Y>>(admin_address());
        Token::deposit(&mut token_pair.token_x_reserve, x);
        Token::deposit(&mut token_pair.token_y_reserve, y);
        let liquidity_cap = borrow_global<LiquidityTokenCapability<X, Y>>(admin_address());
        let mint_token = Token::mint_with_capability(&liquidity_cap.mint, liquidity);
        update_token_pair<X,Y>(x_reserve, y_reserve);

        mint_token
    }


    public fun burn<X: store, Y: store>(
        to_burn: Token::Token<LiquidityToken<X, Y>>,
    ): (Token::Token<X>, Token::Token<Y>) acquires TokenPair, LiquidityTokenCapability {
        let to_burn_value = (Token::value(&to_burn) as u128);
        let token_pair = borrow_global_mut<TokenPair<X, Y>>(admin_address());
        let x_reserve = (Token::value(&token_pair.token_x_reserve) as u128);
        let y_reserve = (Token::value(&token_pair.token_y_reserve) as u128);
        let total_supply = Token::market_cap<LiquidityToken<X, Y>>();
        let x =  SafeMath::safe_mul_div(to_burn_value, x_reserve, total_supply);
        let y = SafeMath::safe_mul_div(to_burn_value, y_reserve, total_supply);
        assert(x > 0 && y > 0, ERROR_SWAP_BURN_CALC_INVALID);
        burn_liquidity(to_burn);
        let x_token = Token::withdraw(&mut token_pair.token_x_reserve, x);
        let y_token = Token::withdraw(&mut token_pair.token_y_reserve, y);
        update_token_pair<X,Y>(x_reserve, y_reserve);
        (x_token, y_token)
    }

    fun burn_liquidity<X: store, Y: store>(
        to_burn: Token::Token<LiquidityToken<X, Y>>
    )acquires LiquidityTokenCapability {
        let liquidity_cap = borrow_global<LiquidityTokenCapability<X, Y>>(admin_address());
        Token::burn_with_capability<LiquidityToken<X, Y>>(&liquidity_cap.burn, to_burn);
    }

    /// Get reserves of a token pair.
    /// The order of type args should be sorted.
    public fun get_reserves<X: store, Y: store>(): (u128, u128) acquires TokenPair {
        let token_pair = borrow_global<TokenPair<X, Y>>(admin_address());
        let x_reserve = Token::value(&token_pair.token_x_reserve);
        let y_reserve = Token::value(&token_pair.token_y_reserve);
//        let last_block_timestamp = token_pair.last_block_timestamp;
        (x_reserve, y_reserve)
    }

    public fun swap<X: store, Y: store>(
        x_in: Token::Token<X>,
        y_out: u128,
        y_in: Token::Token<Y>,
        x_out: u128,
    ): (Token::Token<X>, Token::Token<Y>, Token::Token<X>, Token::Token<Y>) acquires TokenPair {
        let x_in_value = Token::value(&x_in);
        let y_in_value = Token::value(&y_in);
        assert(x_in_value > 0 || y_in_value > 0, ERROR_SWAP_TOKEN_INSUFFICIENT);
        let (x_reserve, y_reserve) = get_reserves<X, Y>();
        let token_pair = borrow_global_mut<TokenPair<X, Y>>(admin_address());
        Token::deposit(&mut token_pair.token_x_reserve, x_in);
        Token::deposit(&mut token_pair.token_y_reserve, y_in);
        let x_swapped = Token::withdraw(&mut token_pair.token_x_reserve, x_out);
        let y_swapped = Token::withdraw(&mut token_pair.token_y_reserve, y_out);
            {
                let x_reserve_new = Token::value(&token_pair.token_x_reserve);
                let y_reserve_new = Token::value(&token_pair.token_y_reserve);
                let (x_adjusted, y_adjusted);
                x_adjusted = x_reserve_new * 1000 - x_in_value * 3;
                y_adjusted = y_reserve_new * 1000 - y_in_value * 3;
                // x_adjusted, y_adjusted >= x_reserve, y_reserve * 1000000
                let cmp_order = SafeMath::safe_compare_u256(x_adjusted, y_adjusted, x_reserve, y_reserve * 1000000);
                assert((EQUAL == cmp_order || GREATER_THAN == cmp_order), ERROR_SWAP_SWAPOUT_CALC_INVALID);
            };

        let (x_swap_fee, y_swap_fee);
        // cacl and handle swap fee, default fee rate is 3/1000
        if (get_swap_fee_switch()) {
            let (actual_fee_operation_numerator, actual_fee_operation_denominator) = cacl_actual_swap_fee_operation_rate<X, Y>();
            x_swap_fee = Token::withdraw(&mut token_pair.token_x_reserve, SafeMath::safe_mul_div(x_in_value, actual_fee_operation_numerator, actual_fee_operation_denominator));
            y_swap_fee = Token::withdraw(&mut token_pair.token_y_reserve, SafeMath::safe_mul_div(y_in_value, actual_fee_operation_numerator, actual_fee_operation_denominator));
        }else{
            x_swap_fee = Token::zero();
            y_swap_fee = Token::zero();
        };

        update_token_pair<X,Y>(x_reserve, y_reserve);
        (x_swapped, y_swapped, x_swap_fee, y_swap_fee)
    }


    /// Emit add liquidity event
    public fun emit_add_liquidity_event<X: store, Y:store>(
        signer: &signer,
        liquidity: u128,
        amount_x_desired: u128,
        amount_y_desired: u128,
        amount_x_min: u128,
        amount_y_min: u128,
    ):() acquires TokenPair {
        let token_pair = borrow_global_mut<TokenPair<X, Y>>(admin_address());
        Event::emit_event(&mut token_pair.add_liquidity_event, AddLiquidityEvent {
            x_token_code: Token::token_code<X>(),
            y_token_code: Token::token_code<Y>(),
            signer: Signer::address_of(signer),
            liquidity,
            amount_x_desired,
            amount_y_desired,
            amount_x_min,
            amount_y_min,
        });
    }

    /// Emit remove liquidity event
    public fun emit_remove_liquidity_event<X: store, Y:store>(
        signer: &signer,
        liquidity: u128,
        amount_x_min: u128,
        amount_y_min: u128,
    ):() acquires TokenPair {
        let token_pair = borrow_global_mut<TokenPair<X, Y>>(admin_address());
        Event::emit_event(&mut token_pair.remove_liquidity_event, RemoveLiquidityEvent {
            x_token_code: Token::token_code<X>(),
            y_token_code: Token::token_code<Y>(),
            signer: Signer::address_of(signer),
            liquidity,
            amount_x_min,
            amount_y_min,
        });
    }

    /// Emit swap event
    public fun emit_swap_event<X: store, Y:store>(
        signer: &signer,
        x_in: u128,
        y_out: u128,
    ):() acquires TokenPair {
        let token_pair = borrow_global_mut<TokenPair<X, Y>>(admin_address());
        Event::emit_event(&mut token_pair.swap_event, SwapEvent {
            x_token_code: Token::token_code<X>(),
            y_token_code: Token::token_code<Y>(),
            signer: Signer::address_of(signer),
            x_in,
            y_out,
        });
    }

    /// Emit swap fee event
    public fun emit_swap_fee_event<X: store, Y:store>(
        account_address: address,
        swap_fee: u128,
        fee_out: u128,
    ):() acquires TokenPair {
        let token_pair = borrow_global_mut<TokenPair<X, Y>>(admin_address());
        Event::emit_event(&mut token_pair.swap_fee_event, SwapFeeEvent {
            x_token_code: Token::token_code<X>(),
            y_token_code: Token::token_code<Y>(),
            signer: account_address,
            fee_addree: fee_address(),
            swap_fee,
            fee_out,
        });
    }


    /// Caller should call this function to determine the order of A, B
    public fun compare_token<X: store, Y: store>(): u8 {
        let x_bytes = BCS::to_bytes<Token::TokenCode>(&Token::token_code<X>());
        let y_bytes = BCS::to_bytes<Token::TokenCode>(&Token::token_code<Y>());
        let ret : u8 = Compare::cmp_bcs_bytes(&x_bytes, &y_bytes);
        ret
    }

    fun assert_admin(signer: &signer) {
        assert(Signer::address_of(signer) == admin_address(), ERROR_SWAP_PRIVILEGE_INSUFFICIENT);
    }

    public fun assert_is_token<TokenType: store>() : bool {
        assert(Token::token_address<TokenType>() != @0x0, ERROR_SWAP_TOKEN_NOT_EXISTS);
        true
    }

    fun admin_address(): address {
        @0x3db7a2da7444995338a2413b151ee437
    }

    public fun fee_address(): address {
        @0xd231d9da8e37fc3d9ff3f576cf978535
    }

    public fun get_swap_fee_switch(): bool {
        SWAP_FEE_SWITCH_ON
    }

    // TWAP price oracle, include update reserves and, on the first call per block, price accumulators
    fun update_token_pair<X: store, Y: store>(
        x_reserve: u128,
        y_reserve: u128,
    ): () acquires TokenPair{
        let token_pair = borrow_global_mut<TokenPair<X, Y>>(admin_address());
        // let x_reserve0 = Token::value(&token_pair.token_x_reserve);
        // let y_reserve0 = Token::value(&token_pair.token_y_reserve);
        let last_block_timestamp = token_pair.last_block_timestamp;
        let block_timestamp = Timestamp::now_seconds();
        let time_elapsed = (block_timestamp - last_block_timestamp as u128);
        if (time_elapsed > 0 && x_reserve !=0 && y_reserve != 0){
            //TODO avoid overflow and loss precision ?
            token_pair.last_price_x_cumulative = token_pair.last_price_x_cumulative + (y_reserve / x_reserve * time_elapsed);
            token_pair.last_price_y_cumulative = token_pair.last_price_y_cumulative + (x_reserve / y_reserve * time_elapsed);
        };

        token_pair.last_block_timestamp = block_timestamp;
    }

    /// if swap fee deposit to fee address fail, return back to lp pool
    public fun return_back_to_lp_pool<X: store, Y: store>(
        x_in: Token::Token<X>,
        y_in: Token::Token<Y>,
    ): () acquires TokenPair {
        let token_pair = borrow_global_mut<TokenPair<X, Y>>(admin_address());
        Token::deposit(&mut token_pair.token_x_reserve, x_in);
        Token::deposit(&mut token_pair.token_y_reserve, y_in);
    }

    public fun cacl_actual_swap_fee_operation_rate<X: store, Y: store>(): (u128, u128) {
        let (fee_numerator, fee_denominator) = query_poundage_rate<X, Y>();
        let (operation_numerator, operation_denominator) = get_swap_fee_operation_rate();
        ((fee_numerator * operation_numerator as u128), (fee_denominator * operation_denominator as u128))
    }

    public fun get_swap_fee_operation_rate(): (u64, u64) {
        (20, 100)
    }

    /// swap fee allocation mode: LP Providor 80%, Operation management 20%
    /// TODO(BobOng): Poundage number of liquidity token pair
    public fun query_poundage_rate<X: store, Y: store>(): (u64, u64) {
        (3, 1000)
    }
}
}