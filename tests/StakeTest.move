//! account: admin, 0x4783d08fb16990bd35d83f3e23bf93b8, 200000 0x1::STC::STC
//! account: feetokenholder, 0x9350502a3af6c617e9a42fa9e306a385, 400000 0x1::STC::STC
//! account: feeadmin, 0xd231d9da8e37fc3d9ff3f576cf978535
//! account: exchanger, 100000 0x1::STC::STC
//! account: alice, 10000000000 0x1::STC::STC
//! account: flyadmin, 0xA4c60527238c2893deAF3061B759c11E, 1000000000000000000 0x1::STC::STC
//! account: faiadmin, 0xfe125d419811297dfab03c61efec0bc9, 1000000000000000000 0x1::STC::STC


//! block-prologue
//! author: genesis
//! block-number: 1
//! block-time: 1631244204293
//! new-transaction
//! sender: faiadmin
address faiadmin = {{faiadmin}};
    script {
        use 0xfe125d419811297dfab03c61efec0bc9::TokenMock::{Self, FAI};

        fun token_init(signer: signer) {
            TokenMock::register_token<FAI>(&signer, 9u8);
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
//! sender: alice
address alice = {{alice}};
script {
    use 0x1::Account;
    use 0xA4c60527238c2893deAF3061B759c11E::FLY;
    use 0xfe125d419811297dfab03c61efec0bc9::TokenMock::{FAI};
    use 0x4783d08fb16990bd35d83f3e23bf93b8::CommonHelper;

    fun init_account(signer: signer) {
        CommonHelper::safe_mint<FAI>(&signer, 6000000000000u128);
        Account::do_accept_token<FLY::FLY>(&signer);
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
    use 0xA4c60527238c2893deAF3061B759c11E::FLY;

    fun init_account(signer: signer) {
        Initialize::initialize_treasury(&signer);
        Account::pay_from<FLY::FLY>(&signer, @alice, 10000000000u128);
    }
}
// check: EXECUTED

//! new-transaction
//! sender: admin
address admin = {{admin}};
script {
    use 0x1::STC::STC;
    use 0xA4c60527238c2893deAF3061B759c11E::FLY::{FLY};
    use 0xfe125d419811297dfab03c61efec0bc9::TokenMock::{FAI};
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
    use 0xA4c60527238c2893deAF3061B759c11E::FLY;
    use 0xA4c60527238c2893deAF3061B759c11E::Config;
    use 0xA4c60527238c2893deAF3061B759c11E::Initialize;

    fun init_bond_stake(signer: signer) {
        Initialize::initialize_bond_stake(&signer);
        Config::update_stake_config<FLY::FLY>(&signer, 100000000000000000u128, 432000u64);

    }
}
// check: EXECUTED

//! block-prologue
//! author: genesis
//! block-number: 2
//! block-time: 1631245104293
//! new-transaction
//! sender: alice
address alie = {{alice}};
script {
    use 0xA4c60527238c2893deAF3061B759c11E::Stake;

    fun stake(signer: signer) {
        Stake::stake(&signer, 5000000000u128);
    }
}
// check: EXECUTED

//! new-transaction
//! sender: alice
address alie = {{alice}};
script {
    use 0xA4c60527238c2893deAF3061B759c11E::Stake;

    fun stake(signer: signer) {
        Stake::forfeit(&signer);
    }
}
// check: EXECUTED

//! new-transaction
//! sender: alice
address alie = {{alice}};
script {
    use 0xA4c60527238c2893deAF3061B759c11E::Stake;

    fun stake(signer: signer) {
        Stake::stake(&signer, 5000000000u128);
    }
}
// check: EXECUTED

//! block-prologue
//! author: genesis
//! block-number: 3
//! block-time: 1631845104293
//! new-transaction
//! sender: alice
address alie = {{alice}};
script {
    use 0xA4c60527238c2893deAF3061B759c11E::Stake;

    fun calim() {
        Stake::claim();
        Stake::rebase();
        let next_reward_ratio = Stake::next_reward_ratio();
//        0x1::Debug::print(&next_reward_ratio);
        assert(next_reward_ratio == 1094527363184079601, 1);
    }
}
// check: EXECUTED
//
//! block-prologue
//! author: genesis
//! block-number: 4
//! block-time: 1632845104293
//! new-transaction
//! sender: alice
address alie = {{alice}};
script {
    use 0xA4c60527238c2893deAF3061B759c11E::Stake;

    fun unstake(signer: signer) {
        Stake::unstake(&signer, 5000000000u128);
    }
}
// check: EXECUTED
