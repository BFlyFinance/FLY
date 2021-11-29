address 0xb987F1aB0D7879b2aB421b98f96eFb44 {
module Bond {
    use 0x1::Timestamp;
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::FLY;
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::Admin;
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::Config;
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::Treasury;
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::TreasuryHelper;

    struct Info<TokenType: store> {
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

    public fun deposit<TokenType: store>(sender: &signer, amount: u128, max_price: u128)acquires Bond {
        let admin_address = Admin::admin_address();
        decayDebt();
        let (control_var, minimum_price, max_payout, fee, max_debt, vesting_term)
            = Config::get_bond_config<TokenType>();
        // check sender token amount
        // check max debt
        // check price
        let value = TreasuryHelper::value_of<TokenType>(amount);
        let payout = payout_for(value);
        let dao_fee = TreasuryHelper::fee_calc(copy payout, fee);
        let profit = TreasuryHelper::profit_calc(copy payout, copy dao_fee);
        // check payout too small (0.01)
        // check payout bigger than max_payout
        Treasury::deposit<TokenType>(amount);
        Treasury::deposit_dao_fee(fee);
        // mint Voucher for user
        create_voucher(sender, amount, price, vesting_term);



    }

    public fun redeem<TokenType: store>(sender: &signer) acquires Bond {
        let percent = percent_vested_for(Signer::address_of(sender));
        let voucher = borrow_global_mut<Bond<TokenType>>(Singer::address_of(sender));
        let balance = Token::value<FLY::FLY>(voucher.token);
        if (percent == 1) {
            let tokens = Token::withdraw<FLY::FLY>(&mut voucher.token, balance);
            Account::deposit_to_self<FLY::FLY>(sender, tokens);
        } else {
            let amount = bond.payout * percent;
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

    fun payout_for(value: u128): u128 {
        1
    }

    public fun percent_vested_for<TokenType: store>(address: address): u128 acquires Bond {
        let bond = borrow_global<Bond<TokenType>>(address);
        let time_now = Timestamp::now_milliseconds();
        let percent = (time_now - bond.start_time) / bond.vesting;
        if (percent > 1) {
            1
        } else {
            (time_now - bond.last_time) / bond.vesting
        }
    }

}
}