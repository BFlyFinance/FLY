//! account: admin, 0x4783d08fb16990bd35d83f3e23bf93b8, 200000 0x1::STC::STC
//! account: feetokenholder, 0x9350502a3af6c617e9a42fa9e306a385, 400000 0x1::STC::STC
//! account: feeadmin, 0xd231d9da8e37fc3d9ff3f576cf978535
//! account: exchanger, 100000 0x1::STC::STC
//! account: alice, 10000000000 0x1::STC::STC
//! account: flyadmin, 0xC137657E5aeD5099592BA07c8ab44CC5, 1000000000000000000 0x1::STC::STC


//! block-prologue
//! author: genesis
//! block-number: 1
//! block-time: 1631244204293
//! new-transaction
//! sender: flyadmin
address flyadmin = {{flyadmin}};
script {
    use 0xC137657E5aeD5099592BA07c8ab44CC5::TokenMock::{Self, FAI};

    fun token_init(signer: signer) {
        TokenMock::register_token<FAI>(&signer, 9u8);
    }
}

// check: EXECUTED

//! new-transaction
//! sender: alice
address alice = {{alice}};
script {
    use 0xC137657E5aeD5099592BA07c8ab44CC5::TokenMock::{FAI};
    use 0x4783d08fb16990bd35d83f3e23bf93b8::CommonHelper;

    fun init_account(signer: signer) {
        CommonHelper::safe_mint<FAI>(&signer, 6000000000000u128);
    }
}
// check: EXECUTED

//! new-transaction
//! sender: flyadmin
address flyadmin = {{flyadmin}};
script {
    use 0xC137657E5aeD5099592BA07c8ab44CC5::Initialize;

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
    use 0xC137657E5aeD5099592BA07c8ab44CC5::FLY::{FLY};
    use 0xC137657E5aeD5099592BA07c8ab44CC5::TokenMock::{FAI};
    use 0x4783d08fb16990bd35d83f3e23bf93b8::TokenSwapRouter;

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
    use 0x1::STC;
    use 0xC137657E5aeD5099592BA07c8ab44CC5::Config;
    use 0xC137657E5aeD5099592BA07c8ab44CC5::Initialize;

    fun init_bond_stake(signer: signer) {
        Initialize::initialize_bond_stake(&signer);
        Config::update_bond_config<STC::STC>(&signer, 1000u128, 1u128, 10000000u128, 1000000000000000000u128, 10000000000000u128, 10000u128);

    }
}
// check: EXECUTED

//! new-transaction
//! sender: alice
address alice = {{alice}};
script {
    use 0x1::STC;
    use 0xC137657E5aeD5099592BA07c8ab44CC5::Bond;
    use 0xC137657E5aeD5099592BA07c8ab44CC5::ExponentialU256;

    fun deposit_stc_bond(signer: signer) {
        Bond::deposit<STC::STC>(&signer, 1000000u128, 100000000000000000000u128);
        let bond_price = Bond::bond_price<STC::STC>();
        assert(ExponentialU256::mantissa_to_u128(bond_price) == 1000099999980000000, 1);
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
    use 0xC137657E5aeD5099592BA07c8ab44CC5::Bond;
    use 0xC137657E5aeD5099592BA07c8ab44CC5::ExponentialU256;

    fun redeem_stc_bond(signer: signer) {
        let price = Bond::bond_price<STC::STC>();
        let debt_ratio = Bond::debt_ratio<STC::STC>();
        0x1::Debug::print(&ExponentialU256::mantissa_to_u128(price));
        0x1::Debug::print(&ExponentialU256::mantissa_to_u128(debt_ratio));
        Bond::redeem<STC::STC>(&signer);
    }
}
