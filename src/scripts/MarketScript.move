address 0x164FbB953f822FBBA95d582B1794687C {
module MarketScript {
    use 0x164FbB953f822FBBA95d582B1794687C::Bond;
    use 0x164FbB953f822FBBA95d582B1794687C::Stake;

    public(script) fun buy_bond<TokenType: copy+drop+store>(sender: signer, amount: u128, max_price: u128) {
        Bond::deposit<TokenType>(&sender, amount, max_price);
    }

    public(script) fun redeem<TokenType: copy+drop+store>(sender: signer) {
        Bond::redeem<TokenType>(&sender);
    }

    public(script) fun bond_price<TokenType: copy+drop+store>(): u128 {
        let ret = Bond::bond_price_usd<TokenType>();
        ret
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