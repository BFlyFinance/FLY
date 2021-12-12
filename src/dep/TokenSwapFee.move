// Copyright (c) The Elements Studio Core Contributors
// SPDX-License-Identifier: Apache-2.0

address 0x3db7a2da7444995338a2413b151ee437 {
module TokenSwapFee {
    use 0x3db7a2da7444995338a2413b151ee437::TokenSwap::{Self};
    use 0x1::Account;
    use 0x1::Token;
    use 0x3db7a2da7444995338a2413b151ee437::TokenSwapLibrary;
    use 0x9350502a3af6c617e9a42fa9e306a385::BX_USDT::BX_USDT;

    const ERROR_ROUTER_SWAP_FEE_MUST_NOT_NEGATIVE: u64 = 1031;
    const ERROR_SWAP_INVALID_TOKEN_PAIR: u64 = 2000;

    public fun handle_token_swap_fee<X: store, Y: store>(tx_address: address, token_x: Token::Token<X>){
        intra_handle_token_swap_fee<X, Y, BX_USDT>(tx_address, token_x)
    }

    /// X is token to pay for fee
    fun intra_handle_token_swap_fee<X: store, Y: store, FeeToken: store>(tx_address: address, token_x: Token::Token<X>){
        let fee_address = TokenSwap::fee_address();
        let (fee_handle, swap_fee, fee_out);
        // the token to pay for fee, is fee token
        if (Token::is_same_token<X, FeeToken>()) {
            (fee_handle, swap_fee, fee_out) = swap_fee_direct_deposit<X, Y>(token_x);
        } else {
            // check [X, FeeToken] token pair exist
            let fee_token_pair_exist = TokenSwap::swap_pair_exists<X, FeeToken>();
            let fee_address_accept_fee_token = Account::is_accepts_token<FeeToken>(fee_address);
            if (fee_token_pair_exist && fee_address_accept_fee_token) {
                (fee_handle, swap_fee, fee_out)= swap_fee_swap<X, FeeToken>(token_x);
            }else{
                // if fee address has not accept the token pay for fee, the swap fee will retention in LP pool
                (fee_handle, swap_fee, fee_out) = swap_fee_direct_deposit<X, Y>(token_x);
            };
        };
        if(fee_handle){
            // fee token and the token to pay for fee compare
            let order = TokenSwap::compare_token<X, Y>();
            assert(order != 0, ERROR_SWAP_INVALID_TOKEN_PAIR);
            if (order == 1) {
                TokenSwap::emit_swap_fee_event<X, Y>(tx_address, swap_fee, fee_out);
            }else{
                TokenSwap::emit_swap_fee_event<Y, X>(tx_address, swap_fee, fee_out);
            };
        }
    }


    fun swap_fee_direct_deposit<X: store, Y: store>(token_x: Token::Token<X>):(bool, u128, u128) {
        let fee_address = TokenSwap::fee_address();
        if (Account::is_accepts_token<X>(fee_address)) {
            let x_value = Token::value(&token_x);
            Account::deposit(fee_address, token_x);
            (true, x_value, x_value)
        //if swap fee deposit to fee address fail, return back to lp pool
        } else {
            let order = TokenSwap::compare_token<X, Y>();
            assert(order != 0, ERROR_SWAP_INVALID_TOKEN_PAIR);
            if (order == 1) {
                TokenSwap::return_back_to_lp_pool<X, Y>(token_x, Token::zero());
            } else {
                TokenSwap::return_back_to_lp_pool<Y, X>(Token::zero(), token_x);
            };
            (false, 0, 0)
        }
    }

    fun swap_fee_swap<X: store, FeeToken: store>(token_x: Token::Token<X>): (bool, u128, u128) {
        let x_value = Token::value(&token_x);
        // just return, not assert error
        if (x_value == 0) {
            Token::destroy_zero(token_x);
            return (false, 0, 0)
        };

        let fee_address = TokenSwap::fee_address();
        let order = TokenSwap::compare_token<X, FeeToken>();
        assert(order != 0, ERROR_SWAP_INVALID_TOKEN_PAIR);
//        let x_value = Token::value( &token_x);
        let (reserve_x, reserve_fee) = TokenSwap::get_reserves<X, FeeToken>();
        let fee_out = TokenSwapLibrary::get_amount_out(x_value, reserve_x, reserve_fee);
        let (token_x_out, token_fee_out);
        let (token_x_fee, token_fee_fee);
        if (order == 1) {
            (token_x_out, token_fee_out, token_x_fee, token_fee_fee) = TokenSwap::swap<X, FeeToken>(token_x, fee_out, Token::zero(), 0);
        } else {
            (token_fee_out, token_x_out, token_fee_fee, token_x_fee) = TokenSwap::swap<FeeToken, X>(Token::zero(), 0, token_x, fee_out);
        };
        Token::destroy_zero(token_x_out);
        Account::deposit(fee_address, token_fee_out);
        Token::destroy_zero(token_fee_fee);
        swap_fee_direct_deposit<X, FeeToken>(token_x_fee);
        (true, x_value, fee_out)
    }

}
}