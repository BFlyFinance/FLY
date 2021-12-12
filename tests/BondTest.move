//! account: admin, 0x3db7a2da7444995338a2413b151ee437, 200000 0x1::STC::STC
//! account: feetokenholder, 0x9350502a3af6c617e9a42fa9e306a385, 400000 0x1::STC::STC
//! account: feeadmin, 0xd231d9da8e37fc3d9ff3f576cf978535
//! account: exchanger, 100000 0x1::STC::STC
//! account: alice, 10000000000 0x1::STC::STC
//! account: flyadmin, 0xb987F1aB0D7879b2aB421b98f96eFb44, 1000000000000000000 0x1::STC::STC


//! block-prologue
//! author: genesis
//! block-number: 1
//! block-time: 1631244104293
//! new-transaction
//! sender: flyadmin
address flyadmin = {{flyadmin}};
script {
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::TokenMock::{Self, FAI};

    fun token_init(signer: signer) {
        TokenMock::register_token<FAI>(&signer, 9u8);
    }
}

// check: EXECUTED

//! new-transaction
//! sender: alice
address alice = {{alice}};
script {
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::TokenMock::{FAI};
    use 0x3db7a2da7444995338a2413b151ee437::CommonHelper;

    fun init_account(signer: signer) {
        CommonHelper::safe_mint<FAI>(&signer, 6000000000000u128);
    }
}
// check: EXECUTED

//! new-transaction
//! sender: flyadmin
address flyadmin = {{flyadmin}};
script {
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::Initialize;

    fun init_account(signer: signer) {
        Initialize::initialize_treasury(&signer);
    }
}
// check: EXECUTED

//! new-transaction
//! sender: admin
address admin = {{admin}};
script {
    use 0x1::STC::STC;
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::FLY::{FLY};
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::TokenMock::{FAI};
    use 0x3db7a2da7444995338a2413b151ee437::TokenSwapRouter;

    fun register_token_pair(signer: signer) {
        //token pair register must be swap admin account
        TokenSwapRouter::register_swap_pair<FLY, FAI>(&signer);
        assert(TokenSwapRouter::swap_pair_exists<FLY, FAI>(), 111);

        TokenSwapRouter::register_swap_pair<FLY, STC>(&signer);
        assert(TokenSwapRouter::swap_pair_exists<FLY, STC>(), 112);
    }
}
// check: EXECUTED

//! new-transaction
//! sender: flyadmin
address flyadmin = {{flyadmin}};
script {
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::Initialize;

    fun init_bond_stake(signer: signer) {
        Initialize::initialize_bond_stake(&signer);
    }
}
// check: EXECUTED

//! new-transaction
//! sender: alice
address alice = {{alice}};
script {
    use 0x1::STC;
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::Bond;

    fun deposit_stc_bond(signer: signer) {
        Bond::deposit<STC::STC>(&signer, 1000000u128, 100000000000000000000u128);
        let debt_ratio = Bond::debt_ratio<STC::STC>();
        0x1::Debug::print(&debt_ratio);
    }
}
// check: EXECUTED

//! block-prologue
//! author: genesis
//! block-number: 2
//! block-time: 1631254204293
//! new-transaction
//! sender: alice
address alice = {{alice}};
script {
    use 0x1::STC;
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::Bond;

    fun redeem_stc_bond(signer: signer) {
        let price = Bond::bond_price<STC::STC>();
        let debt_ratio = Bond::debt_ratio<STC::STC>();
        0x1::Debug::print(&price);
        0x1::Debug::print(&debt_ratio);
        Bond::redeem<STC::STC>(&signer);
    }
}
