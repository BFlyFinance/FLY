address 0xA4c60527238c2893deAF3061B759c11E {
module InitializeScript {

    use 0x1::STC::STC;
//    use 0xA4c60527238c2893deAF3061B759c11E::FAIMock;
    use 0xA4c60527238c2893deAF3061B759c11E::Config;
    use 0xA4c60527238c2893deAF3061B759c11E::FLY::{FLY};
    use 0xA4c60527238c2893deAF3061B759c11E::Initialize;
    use 0x4783d08fb16990bd35d83f3e23bf93b8::TokenSwapRouter;
    use 0xfe125d419811297dfab03c61efec0bc9::FAI::{FAI};


//    public(script) fun safe_mint<TokenType: store>(account: signer, token_amount: u128) {
//        let is_accept_token = Account::is_accepts_token<TokenType>(Signer::address_of(&account));
//        if (!is_accept_token) {
//            Account::do_accept_token<TokenType>(&account);
//        };
//        let token = TokenMock::mint_token<TokenType>(token_amount);
//        Account::deposit<TokenType>(Signer::address_of(&account), token);
//    }

    public(script) fun initialize_treasury(account: signer) {

//        TokenMock::register_token<FAI>(&account, 9u8);
        Initialize::initialize_treasury(&account);

    }

    public(script) fun initialize_swap(account: signer) {
        //token pair register must be swap admin account
        TokenSwapRouter::register_swap_pair<FLY, FAI>(&account);
        assert(TokenSwapRouter::swap_pair_exists<FLY, FAI>(), 111);

        TokenSwapRouter::register_swap_pair<FLY, STC>(&account);
        assert(TokenSwapRouter::swap_pair_exists<FLY, STC>(), 112);

    }

    public(script) fun initialize_bond_stake(account: signer) {
        Initialize::initialize_bond_stake(&account);
    }

    public(script) fun init_oracle(account: signer) {
        Initialize::init_oracle(&account);
    }

    public(script) fun init_bond<TokenType: store+drop+copy>(
        account: signer,
        control_var: u128,
        minimum_price: u128,
        max_payout: u128,
        fee: u128,
        max_debt: u128,
        vesting_term: u128

    ) {
        Config::init_bond_config<TokenType>(
            &account,
            control_var,
            minimum_price,
            max_payout,
            fee,
            max_debt,
            vesting_term
        );
    }
}
}
