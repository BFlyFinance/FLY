address 0xb987F1aB0D7879b2aB421b98f96eFb44 {
module FLY {
    use 0x1::Account;
    use 0x1::Token ;
    use 0x1::Treasury;

    struct FLY has copy, drop, store {}

    const FLY_PRECISION: u8 = 9;

    public fun initialize(account: &signer): (Token::MintCapability<FLY>, Token::BurnCapability<FLY>) {
        Token::register_token<FLY>(account, FLY_PRECISION);
        Account::do_accept_token<FLY>(account);
        let mint_cap = Token::remove_mint_capability<FLY>(account);
        let burn_cap = Token::remove_burn_capability<FLY>(account);
        (mint_cap, burn_cap)
    }

    public fun mint_with_cap(amount: u128, cap: &Token::MintCapability<FLY>): Token::Token<FLY>
    {
        Token::mint_with_capability<FLY>(
            cap,
            amount
        )
    }

    public fun burn_with_cap(amount: Token::Token<FLY>, cap: &Token::BurnCapability<FLY>)
    {
        Token::burn_with_capability<FLY>(
            cap,
            amount
        )
    }

    public fun deposit_to_treasury(amount: Token::Token<FLY>) {
        Treasury::deposit<FLY>(amount)
    }

    public fun treasury_balance(): u128 {
        Treasury::balance<FLY>()
    }
}
}
