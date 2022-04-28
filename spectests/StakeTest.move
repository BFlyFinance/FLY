//# init -n dev --public-keys SwapAdmin=0x5510ddb2f172834db92842b0b640db08c2bc3cd986def00229045d78cc528ac5 FaiAdmin=0x523d767f264a27a1f68f6a45cd9084ee2c827e05edacc747b701cba39e684110 FLYAdmin=0x5c290bb35aba879ca20e25ce81082c28db82650b32027fda13d4c6a2d2891cea

//# faucet --addr SwapAdmin --amount 100000000000000

//# faucet --addr FLYAdmin --amount 100000000000000000

//# faucet --addr FaiAdmin --amount 1000000000000000

//# faucet --addr alice --amount 1000000000000000

//# faucet --addr bob --amount 1000000000000000

//# block --timestamp 1631244204293

//# run --signers alice
script {
    use StarcoinFramework::Account;
    use FaiAdmin::FAI::{FAI};
    use FLYAdmin::FLY::{FLY};

    fun init_account(signer: signer) {
        Account::do_accept_token<FLY>(&signer);
        Account::do_accept_token<FAI>(&signer);
    }
}
// check: EXECUTED

//# run --signers FaiAdmin
script {
    use FaiAdmin::InitializeScript;
    use FaiAdmin::STCVaultPoolA;

    fun fai_init(signer: signer) {
        STCVaultPoolA::initialize_event(&signer);
        InitializeScript::initialize(signer);
    }
}
// CHECK: EXECUTED

//# run --signers FaiAdmin
script {
    use StarcoinFramework::PriceOracleScripts;
    use StarcoinFramework::STCUSDOracle;

    fun init_stcusd_oracle(signer: signer) {
        PriceOracleScripts::init_data_source<STCUSDOracle::STCUSD>(signer, 1000000000000000);
    }
}

//# run --signers FLYAdmin
script {
    use StarcoinFramework::PriceOracleScripts;
    use StarcoinFramework::STCUSDOracle;

    fun init_stcusd_oracle(signer: signer) {
        PriceOracleScripts::init_data_source<STCUSDOracle::STCUSD>(signer, 15280);
    }
}

//# run --signers FaiAdmin
script {
    use StarcoinFramework::Account;
    use FaiAdmin::STCVaultPoolA;
    use FaiAdmin::FAI;

    fun token_init(signer: signer) {

        STCVaultPoolA::create_vault(&signer);
        STCVaultPoolA::deposit(&signer, 1000000000000u128);
        STCVaultPoolA::borrow_fai(&signer, 0u128);

        Account::pay_from<FAI::FAI>(&signer, @alice, 100000000000000u128);
    }
}
// CHECK: EXECUTED

//# run --signers FLYAdmin
script {
    use StarcoinFramework::Account;
    use FLYAdmin::Initialize;
    use FLYAdmin::FLY;

    fun init_account(signer: signer) {
        Initialize::initialize_treasury(&signer);
        Account::pay_from<FLY::FLY>(&signer, @alice, 10000000000u128);
    }
}
// check: EXECUTED

//# run --signers SwapAdmin
script {
    use StarcoinFramework::STC::STC;
    use FLYAdmin::FLY::{FLY};
    use FaiAdmin::FAI::FAI;
    use SwapAdmin::TokenSwapRouter;

    fun register_token_pair(signer: signer) {
        //token pair register must be swap admin account
        TokenSwapRouter::register_swap_pair<FLY, FAI>(&signer);
        assert!(TokenSwapRouter::swap_pair_exists<FLY, FAI>(), 111);

        TokenSwapRouter::register_swap_pair<FLY, STC>(&signer);
        assert!(TokenSwapRouter::swap_pair_exists<FLY, STC>(), 112);
    }
}
// check: EXECUTED

//# run --signers FLYAdmin
script {
    use FLYAdmin::FLY;
    use FLYAdmin::Config;
    use FLYAdmin::Initialize;

    fun init_bond_stake(signer: signer) {
        Initialize::initialize_bond_stake(&signer);
        Config::update_stake_config<FLY::FLY>(&signer, 100000000000000000u128, 432000u64);

    }
}
// check: EXECUTED

//# block --timestamp 1631245104293

//# run --signers alice
script {
    use FLYAdmin::Stake;

    fun stake(signer: signer) {
        Stake::stake(&signer, 5000000000u128);
    }
}
// check: EXECUTED

//# run --signers alice
script {
    use FLYAdmin::Stake;

    fun stake(signer: signer) {
        Stake::forfeit(&signer);
    }
}
// check: EXECUTED

//# run --signers alice
script {
    use FLYAdmin::Stake;

    fun stake(signer: signer) {
        Stake::stake(&signer, 5000000000u128);
    }
}
// check: EXECUTED

//# block --timestamp 1631845104293

//# run --signers alice
script {
    use FLYAdmin::Stake;

    fun calim() {
        Stake::claim();
        Stake::rebase();
        let next_reward_ratio = Stake::next_reward_ratio();
//        StarcoinFramework::Debug::print(&next_reward_ratio);
        assert!(next_reward_ratio == 1094527363184079601, 1);
    }
}
// check: EXECUTED

//# block --timestamp 1632845104293

//# run --signers alice
script {
    use FLYAdmin::Stake;

    fun unstake(signer: signer) {
        Stake::unstake(&signer, 5000000000u128);
    }
}
// check: EXECUTED

//# run --signers FLYAdmin
script {
    use FLYAdmin::Config;

    fun set_global_switch_on(signer: signer) {
        Config::set_global_switch(&signer, true);
    }
}
// check: EXECUTED

//# run --signers alice
script {
    use FLYAdmin::Stake;

    fun stake(signer: signer) {
        Stake::stake(&signer, 5000000000u128);
    }
}
// check: MoveAbort 52993

//# run --signers alice
script {
    use FLYAdmin::Stake;

    fun calim() {
        Stake::claim();
        Stake::rebase();
        let next_reward_ratio = Stake::next_reward_ratio();
        //        StarcoinFramework::Debug::print(&next_reward_ratio);
        assert!(next_reward_ratio == 1094527363184079601, 1);
    }
}
// check: MoveAbort 52993


//# run --signers alice
script {
    use FLYAdmin::Stake;

    fun unstake(signer: signer) {
        Stake::unstake(&signer, 5000000000u128);
    }
}
// check: MoveAbort 52993

//# run --signers FLYAdmin
script {
    use FLYAdmin::Config;

    fun set_global_switch_off(signer: signer) {
        Config::set_global_switch(&signer, false);
    }
}
// check: EXECUTED
