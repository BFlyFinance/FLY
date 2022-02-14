//! account: admin, 0x4783d08fb16990bd35d83f3e23bf93b8, 200000 0x1::STC::STC
//! account: feetokenholder, 0x9350502a3af6c617e9a42fa9e306a385, 400000 0x1::STC::STC
//! account: feeadmin, 0xd231d9da8e37fc3d9ff3f576cf978535
//! account: exchanger, 100000 0x1::STC::STC
//! account: alice, 10000000000000 0x1::STC::STC
//! account: flyadmin, 0xA4c60527238c2893deAF3061B759c11E, 1000000000000000000 0x1::STC::STC
//! account: faiadmin, 0xfe125d419811297dfab03c61efec0bc9, 1000000000000000000 0x1::STC::STC


//! block-prologue
//! author: genesis
//! block-number: 1
//! block-time: 1631244204293
//! new-transaction
//! sender: alice
address alice = {{alice}};
script {
    use 0x1::Account;
    use 0xfe125d419811297dfab03c61efec0bc9::FAI::{FAI};
    use 0xA4c60527238c2893deAF3061B759c11E::FLY::{FLY};

    fun init_account(signer: signer) {
        Account::do_accept_token<FLY>(&signer);
        Account::do_accept_token<FAI>(&signer);
    }
}
// check: EXECUTED

//! new-transaction
//! sender: faiadmin
address faiadmin = {{faiadmin}};
address alice = {{alice}};
script {
    use 0x1::Account;
    use 0xfe125d419811297dfab03c61efec0bc9::FAI;

    fun token_init(signer: signer) {
        FAI::register_token<FAI::FAI>(&signer, 9u8);
        let token = FAI::mint_token<FAI::FAI>(10000000000000000u128);
        Account::deposit_to_self<FAI::FAI>(&signer, token);
        Account::pay_from<FAI::FAI>(&signer, @alice, 100000000000000u128);
}
}
// check: EXECUTED

//! new-transaction
//! sender: flyadmin
address flyadmin = {{flyadmin}};
script {
    use 0xA4c60527238c2893deAF3061B759c11E::Initialize;

    fun init_account(signer: signer) {
        Initialize::init_oracle(&signer);
    }
}
// check: EXECUTED

//! new-transaction
//! sender: flyadmin
address flyadmin = {{flyadmin}};
address alice = {{alice}};
script {
    use 0x1::Account;
    use 0xA4c60527238c2893deAF3061B759c11E::Initialize;
    use 0xA4c60527238c2893deAF3061B759c11E::FLY::{FLY};

    fun init_account(signer: signer) {
        Initialize::initialize_treasury(&signer);
        Account::pay_from<FLY>(&signer, @alice, 1000000000000u128);
    }
}
// check: EXECUTED

//! new-transaction
//! sender: admin
address admin = {{admin}};
script {
    use 0x1::STC::STC;
    use 0xA4c60527238c2893deAF3061B759c11E::FLY::{FLY};
    use 0xfe125d419811297dfab03c61efec0bc9::FAI::{FAI};
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
//! sender: alice
address alice = {{alice}};
script {
    use 0x1::Signer;
    use 0x1::Account;
    use 0x1::STC::STC;
    use 0xA4c60527238c2893deAF3061B759c11E::FLY::{FLY};
    use 0xfe125d419811297dfab03c61efec0bc9::FAI::{FAI};
    use 0x4783d08fb16990bd35d83f3e23bf93b8::TokenSwap;
    use 0x4783d08fb16990bd35d83f3e23bf93b8::TokenSwapRouter;

    fun register_token_pair(signer: signer) {
        TokenSwapRouter::add_liquidity<FLY, STC>(&signer, 10000000000u128, 1000000000000u128, 5000u128, 5000u128);
        TokenSwapRouter::add_liquidity<FLY, FAI>(&signer, 10000000000u128, 1000000000000u128, 5000u128, 5000u128);
        0x1::Debug::print(&Account::balance<TokenSwap::LiquidityToken<STC, FLY>>(Signer::address_of(&signer)));
        0x1::Debug::print(&Account::balance<TokenSwap::LiquidityToken<FAI, FLY>>(Signer::address_of(&signer)));
    }
}
// check: EXECUTED

//! new-transaction
//! sender: flyadmin
address flyadmin = {{flyadmin}};
script {
    use 0xA4c60527238c2893deAF3061B759c11E::Config;
    use 0x4783d08fb16990bd35d83f3e23bf93b8::TokenSwap;
    use 0xA4c60527238c2893deAF3061B759c11E::Initialize;
    use 0xA4c60527238c2893deAF3061B759c11E::FLY::{FLY};
    use 0xfe125d419811297dfab03c61efec0bc9::FAI::{FAI};

fun init_bond_stake(signer: signer) {
        Initialize::initialize_bond_stake(&signer);
        Config::update_bond_config<TokenSwap::LiquidityToken<FAI, FLY>>(&signer, 1000u128, 10000u128, 100000000u128, 1000000000000000000u128, 10000000000000000u128, 10000u128);

    }
}
// check: EXECUTED

//! new-transaction
//! sender: alice
address alice = {{alice}};
script {
    use 0xA4c60527238c2893deAF3061B759c11E::Bond;
    use 0x4783d08fb16990bd35d83f3e23bf93b8::TokenSwap;
    use 0xA4c60527238c2893deAF3061B759c11E::FLY::{FLY};
    use 0xfe125d419811297dfab03c61efec0bc9::FAI::{FAI};

fun deposit_stc_bond(signer: signer) {
        Bond::deposit<TokenSwap::LiquidityToken<FAI, FLY>>(&signer, 1000000u128, 152800000000000000u128);
//        let bond_price = Bond::bond_price_usd<TokenSwap::LiquidityToken<FAI, FLY>>();
//        0x1::Debug::print(&bond_price);
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
    use 0xA4c60527238c2893deAF3061B759c11E::Bond;
    use 0x4783d08fb16990bd35d83f3e23bf93b8::TokenSwap;
    use 0xA4c60527238c2893deAF3061B759c11E::FLY::{FLY};
    use 0xfe125d419811297dfab03c61efec0bc9::FAI::{FAI};

fun redeem_lp_bond(signer: signer) {
    Bond::redeem<TokenSwap::LiquidityToken<FAI, FLY>>(&signer);
    }
}
