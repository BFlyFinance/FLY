address 0xb987F1aB0D7879b2aB421b98f96eFb44 {
module Bond {

    use 0x1::Token;
    use 0x1::Timestamp;
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::FLY;
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::Admin;
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::Config;
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::Treasury;
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::TreasuryHelper;
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::ExponentialU256::{Self, Exp};

    const INSUFFICIENT_AMOUNT: u64 = 1;
    const EXCEEDS_MAX_AMOUNT: u64 = 2;
    const SLIPPAGE_LIMIT: u64 = 2;

    struct Info<TokenType: store> has key {
        total_debt: u128,
        last_update_time: u64,
    }

    struct Bond<TokenType: store> has key, store {
        token: Token<FLY::FLY>,
        payout: u128,
        price_paid: u128,
        start_time: u64,
        last_time: u64,
        vesting: u64
    }

    public fun initialize<TokenType: store>(address: &signer) {

    }

    public fun deposit<TokenType: store>(sender: &signer, amount: u128, max_price: u128)acquires Info, Bond {
        let admin_address = Admin::admin_address();
        decayDebt();
        let (control_var, minimum_price, max_payout, fee, max_debt, vesting_term)
            = Config::get_bond_config<TokenType>();
        // check sender token amount
        assert(Account::balance<TokenType>(Signer::address_of(sender)) >= amount, INSUFFICIENT_AMOUNT);
        // check max debt
        let info = borrow_global<Info<TokenType>>(admin_address);
        assert(info.total_debt <= max_debt, EXCEEDS_MAX_AMOUNT);
        // check price
        let native_price = bond_price<TokenType>();
        assert(ExponentialU256::greater_than_exp(ExponentialU256::exp_direct(max_price), native_price), SLIPPAGE_LIMIT);
        let value = TreasuryHelper::value_of<TokenType>(amount);
        let payout = payout_for<TokenType>(value);
        let dao_fee = TreasuryHelper::fee_calc(copy payout, fee);
        let profit = TreasuryHelper::profit_calc(copy value, copy payout, copy dao_fee);
        // check payout too small (0.01)
        // check payout bigger than max_payout
        Treasury::deposit<TokenType>(amount);
        Treasury::deposit_dao_fee(fee);
        // mint Voucher for user
        create_voucher(sender, amount, price, vesting_term);



    }

    public fun redeem<TokenType: store>(sender: &signer) acquires Bond, Info {
        let admin_address = Admin::admin_address();
        let percent = percent_vested_for(Signer::address_of(sender));
        let voucher = borrow_global_mut<Bond<TokenType>>(Singer::address_of(sender));
        let balance = Token::value<FLY::FLY>(voucher.token);
        let info = borrow_global_mut<Info<TokenType>>(admin_address);
        if (ExponentialU256::equal_exp(percent, ExponentialU256::exp(1, 1))) {
            let tokens = Token::withdraw<FLY::FLY>(&mut voucher.token, balance);
            Account::deposit_to_self<FLY::FLY>(sender, tokens);
            info.total_debt = info.total_debt + balance;
        } else {
            let amount_exp = ExponentialU256::mul_exp(ExponentialU256::exp_direct(bond.payout), percent);
            let amount = ExponentialU256::mantissa_to_u128(amount_exp);
            let tokens = Token::withdraw<FLY::FLY>(&mut voucher.token, amount);
            Account::deposit_to_self<FLY::FLY>(sender, tokens);
        };
        voucher.last_time = Timestamp::now_milliseconds();
    }

    fun create_voucher<TokenType: store>(sender: &signer, amount: u128, price: u128, vesting: u64)acquires Bond {
        let tokens = Treasury::mint_bond_token_with_cap();
        if (exists<Bond<TokenType>>(address)) {
            let voucher = borrow_global_mut<Bond<TokenType>>(Signer::address_of(sender));
            voucher.amount = voucher.amount + amount;
            voucher.price_paid = price;
            voucher.start_time = Timestamp::now_milliseconds();
            voucher.last_time = Timestamp::now_milliseconds();
            voucher.vesting = vesting;
            Token::deposit<FLY::FLY>(&mut voucher.token, tokens);
        } else {
            let voucher = Bond<TokenType> {
                payout: amount,
                price_paid: price,
                start_time: Timestamp::now_milliseconds(),
                last_time: Timestamp::now_milliseconds(),
                vesting: vesting,
                token: Token::zero()
            };
            Token::deposit<FLY::FLY>(&mut voucher.token, tokens);
            move_to(sender, voucher);
        }

    }

    fun payout_for<TokenType: store>(value: u128): u128 {
        let token_price = bond_price<TokenType>();
        let amount_exp = ExponentialU256::div_exp(ExponentialU256::exp_direct(value), token_price);
        ExponentialU256::mantissa_to_u128(amount_exp)
    }

    public fun percent_vested_for<TokenType: store>(address: address): Exp acquires Bond {
        let bond = borrow_global<Bond<TokenType>>(address);
        let time_now = Timestamp::now_milliseconds();
        let percent = (time_now - bond.start_time) / bond.vesting;
        if (percent > 1) {
            ExponentialU256::exp(1, 1)
        } else {
            ExponentialU256::exp((time_now - bond.last_time) as u128, bond.vesting as u128)
        }
    }

    public fun bond_price<TokenType> (): Exp acquires Info{
        let bcv_debt_ratio = ExponentialU256::mul_exp(ExponentialU256::exp(bcv, 1) * debtRatio<TokenType>());
        ExponentialU256::add_exp(bcv_debt_ratio, ExponentialU256::exp(1, 1))
    }

    public fun debt_ratio<TokenType: store>(): Exp acquires Info {
        let admin_address = Admin::admin_address();
        let decay_debt = debt_decay<TokenType>();
        let info = borrow_global_mut<Info<TokenType>>(admin_address);
        let debt = info.total_debt - decay_debt;
        let FLY_amount = Token::market_cap<FLY::FLY>();
        ExponentialU256::exp(debt, FLY_amount)
    }

    fun decay_debt<TokenType: store>() acquires Info {
        let decay_amount = debt_decay<TokenType>();
        let admin_address = Admin::admin_address();
        let info = borrow_global_mut<Info<TokenType>>(admin_address);
        info.total_debt = info.total_debt - decay_amount;
        info.last_update_time = Timestamp::now_milliseconds();
    }

    fun debt_decay<TokenType: store>(): u128 acquires Info {
        let admin_address = Admin::admin_address();
        let info = borrow_global<Info<TokenType>>(admin_address);
        let time_now = Timestamp::now_milliseconds();
        let (_, _, _, _, _, vesting_term)
            = Config::get_bond_config<TokenType>();
        let decay_percent = ExponentialU256::exp((time_now - info.last_update_time) as u128, vesting_term as u128);
        let decay_exp = ExponentialU256::mul_exp(ExponentialU256::exp_direct(info.total_debt), decay_percent);
        let decay_ = ExponentialU256::mantissa_to_u128(decay_exp);
        if (decay_ > info.total_debt) {
            decay_ = *&info.total_debt
        };
        decay_
    }

}
}