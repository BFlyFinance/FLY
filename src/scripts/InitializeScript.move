address 0x7231Eb1A18d8711336B21f6106697253 {
module InitializeScript {

    use 0x1::STC::STC;
    use 0x1::Signer;
    use 0x1::Account;
    use 0x7231Eb1A18d8711336B21f6106697253::FAIMock;
    use 0x7231Eb1A18d8711336B21f6106697253::FLY::{FLY};
    use 0x7231Eb1A18d8711336B21f6106697253::Initialize;
    use 0x4783d08fb16990bd35d83f3e23bf93b8::TokenSwapRouter;
    use 0x7231Eb1A18d8711336B21f6106697253::TokenMock::{Self, FAI};


    public(script) fun safe_mint<TokenType: store>(account: signer, token_amount: u128) {
        let is_accept_token = Account::is_accepts_token<TokenType>(Signer::address_of(&account));
        if (!is_accept_token) {
            Account::do_accept_token<TokenType>(&account);
        };
        let token = TokenMock::mint_token<TokenType>(token_amount);
        Account::deposit<TokenType>(Signer::address_of(&account), token);
    }

    public(script) fun initialize_treasury(account: signer) {

        TokenMock::register_token<FAI>(&account, 9u8);
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

    public(script) fun init_fai(account: signer) {
        FAIMock::initialize(&account);
    }
}
}
