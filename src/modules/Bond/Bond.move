address 0x164FbB953f822FBBA95d582B1794687C {
module Bond {

    use 0x1::Token;
    use 0x1::Signer;
    use 0x1::Account;
    use 0x1::Timestamp;
    use 0x164FbB953f822FBBA95d582B1794687C::FLY;
    use 0x164FbB953f822FBBA95d582B1794687C::Admin;
    use 0x164FbB953f822FBBA95d582B1794687C::Price;
    use 0x164FbB953f822FBBA95d582B1794687C::Config;
    use 0x164FbB953f822FBBA95d582B1794687C::Treasury;
    use 0x164FbB953f822FBBA95d582B1794687C::PriceOracle;
    use 0x164FbB953f822FBBA95d582B1794687C::TreasuryHelper;
    use 0x164FbB953f822FBBA95d582B1794687C::ExponentialU256::{Self, Exp};

    const INSUFFICIENT_AMOUNT: u64 = 1;
    const EXCEEDS_MAX_AMOUNT: u64 = 2;
    const SLIPPAGE_LIMIT: u64 = 3;

    struct Info<TokenType: store> has key {
        total_debt: u128,
        total_purchased: u128,
        last_update_time: u64,
    }

    struct Bond<TokenType: store> has key, store {
        token: Token::Token<FLY::FLY>,
        payout: u128,
        price_paid: u128,
        start_time: u64,
        last_time: u64,
        vesting: u64
    }

    struct MintCap has key, store {
        cap: Treasury::SharedMintCap
    }

    public fun initialize(sender: &signer) {
        let mint_cap = Treasury::get_mint_cap(sender);
        move_to(sender, MintCap {cap: mint_cap});
    }
    public fun initialize_bond<TokenType: copy+drop+store>(sender: &signer) {
        Admin::is_admin(sender);
        move_to(sender, Info<TokenType>{total_debt: 0, total_purchased: 0, last_update_time: Timestamp::now_seconds()});
    }

    public fun deposit<TokenType: copy+drop+store>(sender: &signer, amount: u128, max_price: u128)
    acquires Info, Bond, MintCap {
        let admin_address = Admin::admin_address();
        decay_debt<TokenType>();
        let (_, _, _, fee, max_debt, vesting_term)
            = Config::get_bond_config<TokenType>();
        assert(Account::balance<TokenType>(Signer::address_of(sender)) >= amount, INSUFFICIENT_AMOUNT);
        let info = borrow_global<Info<TokenType>>(admin_address);
        assert(info.total_debt <= max_debt, EXCEEDS_MAX_AMOUNT);
        let native_price = bond_price<TokenType>();
        let usd_price = bond_price_usd<TokenType>();
        let price = ExponentialU256::mantissa_to_u128(copy native_price);
        assert(ExponentialU256::greater_than_exp(ExponentialU256::exp_direct(max_price), native_price), SLIPPAGE_LIMIT);
        assert(max_price >= usd_price, SLIPPAGE_LIMIT);
        let value = TreasuryHelper::value_of<TokenType>(amount);
        let payout = payout_for<TokenType>(value);
        let dao_fee = TreasuryHelper::fee_calc(copy payout, fee);
        Treasury::deposit<TokenType>(sender, amount);
        let mint_cap = borrow_global<MintCap>(admin_address);
        Treasury::deposit_dao_fee_with_cap(dao_fee, &mint_cap.cap);
        let info = borrow_global_mut<Info<TokenType>>(admin_address);
        info.total_debt = info.total_debt + value;
        info.total_purchased = info.total_purchased + amount;
        create_voucher<TokenType>(sender, amount, price, (vesting_term as u64));
    }

    public fun redeem<TokenType: copy+drop+store>(sender: &signer) acquires Bond {
        let percent = percent_vested_for<TokenType>(Signer::address_of(sender));
        let voucher = borrow_global_mut<Bond<TokenType>>(Signer::address_of(sender));
        let balance = Token::value<FLY::FLY>(&voucher.token);
        if (ExponentialU256::equal_exp(copy percent, ExponentialU256::exp(1, 1))) {
            let tokens = Token::withdraw<FLY::FLY>(&mut voucher.token, balance);
            Account::deposit_to_self<FLY::FLY>(sender, tokens);
        } else {
            let amount_exp = ExponentialU256::mul_exp(ExponentialU256::exp_direct(voucher.payout), percent);
            let amount = ExponentialU256::mantissa_to_u128(amount_exp);
            let tokens = Token::withdraw<FLY::FLY>(&mut voucher.token, amount);
            Account::deposit_to_self<FLY::FLY>(sender, tokens);
        };
        voucher.last_time = Timestamp::now_seconds();
    }

    fun create_voucher<TokenType: copy+drop+store>(sender: &signer, amount: u128, price: u128, vesting: u64)
    acquires Bond, MintCap {
        let mint_cap = borrow_global<MintCap>(Admin::admin_address());
        let tokens = Treasury::mint_bond_token_with_cap(amount, &mint_cap.cap);
        if (exists<Bond<TokenType>>(Signer::address_of(sender))) {
            let voucher = borrow_global_mut<Bond<TokenType>>(Signer::address_of(sender));
            voucher.payout = voucher.payout + amount;
            voucher.price_paid = price;
            voucher.start_time = Timestamp::now_seconds();
            voucher.last_time = Timestamp::now_seconds();
            voucher.vesting = vesting;
            Token::deposit<FLY::FLY>(&mut voucher.token, tokens);
        } else {
            let voucher = Bond<TokenType> {
                payout: amount,
                price_paid: price,
                start_time: Timestamp::now_seconds(),
                last_time: Timestamp::now_seconds(),
                vesting: vesting,
                token: Token::zero<FLY::FLY>()
            };
            Token::deposit<FLY::FLY>(&mut voucher.token, tokens);
            move_to(sender, voucher);
        }
    }

    fun payout_for<TokenType: copy+drop+store>(value: u128): u128 acquires Info{
        let token_price = bond_price<TokenType>();
        let amount_exp = ExponentialU256::div_exp(ExponentialU256::exp(value, 1), token_price);
        ExponentialU256::truncate_to_u128(amount_exp)
    }

    fun percent_vested_for<TokenType: copy+drop+store>(address: address): Exp acquires Bond {
        let bond = borrow_global<Bond<TokenType>>(address);
        let time_now = Timestamp::now_seconds();
        let percent = (time_now - bond.start_time) / bond.vesting;
        if (percent > 1) {
            ExponentialU256::exp(1, 1)
        } else {
            let time_delta = time_now - bond.start_time;
            ExponentialU256::exp((time_delta as u128), (bond.vesting as u128))
        }
    }

    public fun percent_vested<TokenType: copy+drop+store>(address: address): u128 acquires Bond {
        let percent_exp = percent_vested_for<TokenType>(address);
        ExponentialU256::mantissa_to_u128(percent_exp)
    }

    public fun bond_price<TokenType: copy+drop+store> (): Exp acquires Info{
        let (bcv, _, _, _, _, _)
        = Config::get_bond_config<TokenType>();
        let bcv_debt_ratio = ExponentialU256::mul_exp(ExponentialU256::exp(bcv, 1), debt_ratio<TokenType>());
        ExponentialU256::add_exp(bcv_debt_ratio, ExponentialU256::exp(1, 1))
    }

    public fun bond_price_usd<TokenType: copy+drop+store>(): u128 acquires Info {
        let native_price_exp = bond_price<TokenType>();
        let token_price = PriceOracle::usdt_price<TokenType>();
        let (price, dec) = Price::unpack(token_price);
        let native_price_exp_mul_price = ExponentialU256::mul_scalar_exp(native_price_exp, price);
        let bond_price_usd_exp = ExponentialU256::div_scalar_exp(native_price_exp_mul_price, dec);
        ExponentialU256::mantissa_to_u128(bond_price_usd_exp)
    }

    public fun debt_ratio<TokenType: copy+drop+store>(): Exp acquires Info {
        let admin_address = Admin::admin_address();
        let decay_debt = debt_decay<TokenType>();
        let info = borrow_global_mut<Info<TokenType>>(admin_address);
        let debt = info.total_debt - decay_debt;
        let fly_amount = Token::market_cap<FLY::FLY>();
        ExponentialU256::exp(debt, fly_amount)
    }

    fun decay_debt<TokenType: drop+copy+store>() acquires Info {
        let decay_amount = debt_decay<TokenType>();
        let admin_address = Admin::admin_address();
        let info = borrow_global_mut<Info<TokenType>>(admin_address);
        info.total_debt = info.total_debt - decay_amount;
        info.last_update_time = Timestamp::now_seconds();
    }

    fun debt_decay<TokenType: drop+copy+store>(): u128 acquires Info {
        let admin_address = Admin::admin_address();
        let info = borrow_global<Info<TokenType>>(admin_address);
        let time_now = Timestamp::now_seconds();
        let (_, _, _, _, _, vesting_term)
            = Config::get_bond_config<TokenType>();
        let time_delta = time_now - info.last_update_time;
        let decay_percent = ExponentialU256::exp((time_delta as u128), (vesting_term as u128));
        let decay_exp = ExponentialU256::mul_exp(ExponentialU256::exp_direct(info.total_debt), decay_percent);
        let decay_ = ExponentialU256::mantissa_to_u128(decay_exp);
        if (decay_ > info.total_debt) {
            decay_ = *&info.total_debt
        };
        decay_
    }
}
}