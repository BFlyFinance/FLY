address 0xC137657E5aeD5099592BA07c8ab44CC5 {
module MarketScript {
    use 0xC137657E5aeD5099592BA07c8ab44CC5::Bond;
    use 0xC137657E5aeD5099592BA07c8ab44CC5::Stake;
    use 0xC137657E5aeD5099592BA07c8ab44CC5::ExponentialU256;

    public(script) fun buy_bond<TokenType: copy+drop+store>(sender: signer, amount: u128, max_price: u128) {
        Bond::deposit<TokenType>(&sender, amount, max_price);
    }

    public(script) fun redeem<TokenType: copy+drop+store>(sender: signer) {
        Bond::redeem<TokenType>(&sender);
    }

    public(script) fun bond_price<TokenType: copy+drop+store>(): u128 {
        let ret = Bond::bond_price<TokenType>();
        ExponentialU256::mantissa_to_u128(ret)
    }

    public(script) fun stake(sender: signer, amount: u128) {
        Stake::stake(&sender, amount);
    }

    public(script) fun unstake(sender: signer, amount: u128) {
        Stake::unstake(&sender, amount);

    }

    public(script) fun forfeit(sender: signer) {
        Stake::forfeit(&sender);
    }



}
}