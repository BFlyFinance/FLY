address FLYAdmin {
module InitializeScript {

    use StarcoinFramework::STC::STC;
    use FLYAdmin::Bond;
    use FLYAdmin::Config;
    use FLYAdmin::Treasury;
    use FLYAdmin::FLY::{FLY};
    use FLYAdmin::Initialize;
    use SwapAdmin::TokenSwapRouter;
    use FaiAdmin::FAI::{FAI};

    public(script) fun initialize_treasury(account: signer) {
        Initialize::initialize_treasury(&account);
    }

    public(script) fun initialize_swap(account: signer) {
        //token pair register must be swap admin account
        TokenSwapRouter::register_swap_pair<FLY, FAI>(&account);
        assert!(TokenSwapRouter::swap_pair_exists<FLY, FAI>(), 111);

        TokenSwapRouter::register_swap_pair<FLY, STC>(&account);
        assert!(TokenSwapRouter::swap_pair_exists<FLY, STC>(), 112);

    }

    public(script) fun initialize_bond<TokenType: store+drop+copy>(account: signer) {
        Bond::initialize_bond<TokenType>(&account);
    }

    public(script) fun init_treasury<TokenType: store+drop+copy>(account: signer) {
        Treasury::initialize_pool<TokenType>(&account);
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
