address FLYAdmin {
module MarketScript {
    use FLYAdmin::Bond;
    use FLYAdmin::Stake;
//    use FLYAdmin::ExponentialU256;

    public(script) fun buy_bond<TokenType: copy+drop+store>(sender: signer, amount: u128, max_price: u128) {
        Bond::deposit<TokenType>(&sender, amount, max_price);
    }

    public(script) fun redeem<TokenType: copy+drop+store>(sender: signer) {
        Bond::redeem<TokenType>(&sender);
    }

//    public(script) fun bond_price<TokenType: copy+drop+store>(): u128 {
//        let ret = Bond::bond_price_usd<TokenType>();
//        ret
//    }

    public(script) fun stake(sender: signer, amount: u128) {
        Stake::stake(&sender, amount);
    }

    public(script) fun unstake(sender: signer, amount: u128) {
        Stake::unstake(&sender, amount);

    }

    public(script) fun forfeit(sender: signer) {
        Stake::forfeit(&sender);
    }

    public(script) fun rebase(_sender: signer) {
        Stake::rebase();
    }

//    public(script) fun debt_ratio<TokenType: copy+drop+store>(): u128 {
//        let debt_ratio_exp = Bond::debt_ratio<TokenType>();
//        ExponentialU256::mantissa_to_u128(debt_ratio_exp)
//    }
}
}