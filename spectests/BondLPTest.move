//# init -n dev --public-keys SwapAdmin=0x5510ddb2f172834db92842b0b640db08c2bc3cd986def00229045d78cc528ac5 FaiAdmin=0x1725f86f6e4492afc3c2a6089d7d53a07ae88297b780464d13bba404a969d189 FLYAdmin=0xd948aab1ee547c97d5d3f91b08e0823f021c8d7d111054c4ae667db8165e2942

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

    fun fai_init(signer: signer) {
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
    use FLYAdmin::Initialize;

    fun init_account(signer: signer) {
        Initialize::init_oracle(&signer);
    }
}
// check: EXECUTED

//# run --signers FLYAdmin
script {
    use StarcoinFramework::Account;
    use FLYAdmin::Initialize;
    use FLYAdmin::FLY::{FLY};

    fun init_account(signer: signer) {
        Initialize::initialize_treasury(&signer);
        Account::pay_from<FLY>(&signer, @alice, 1000000000000u128);
    }
}
// check: EXECUTED

//# run --signers SwapAdmin
script {
    use StarcoinFramework::STC::STC;
    use StarcoinFramework::Token;
    use FLYAdmin::FLY::{FLY};
    use FaiAdmin::FAI::{FAI};
    use SwapAdmin::TokenSwap;
    use SwapAdmin::TokenSwapRouter;

    fun register_token_pair(signer: signer) {
        //token pair register must be swap admin account
        TokenSwapRouter::register_swap_pair<FLY, FAI>(&signer);
        assert!(TokenSwapRouter::swap_pair_exists<FLY, FAI>(), 111);

        TokenSwapRouter::register_swap_pair<FLY, STC>(&signer);
        assert!(TokenSwapRouter::swap_pair_exists<FLY, STC>(), 112);
        StarcoinFramework::Debug::print(&Token::scaling_factor<TokenSwap::LiquidityToken<FAI, FLY>>());
    }
}
// check: EXECUTED

//# run --signers alice
script {
    use StarcoinFramework::Signer;
    use StarcoinFramework::Account;
    use StarcoinFramework::STC::STC;
    use FLYAdmin::FLY::{FLY};
    use FaiAdmin::FAI::{FAI};
    use SwapAdmin::TokenSwap;
    use SwapAdmin::TokenSwapRouter;

    fun register_token_pair(signer: signer) {
        TokenSwapRouter::add_liquidity<FLY, STC>(&signer, 10000000000u128, 1000000000000u128, 5000u128, 5000u128);
        TokenSwapRouter::add_liquidity<FLY, FAI>(&signer, 10000000000u128, 1000000000000u128, 5000u128, 5000u128);
        StarcoinFramework::Debug::print(&Account::balance<TokenSwap::LiquidityToken<STC, FLY>>(Signer::address_of(&signer)));
        StarcoinFramework::Debug::print(&Account::balance<TokenSwap::LiquidityToken<FAI, FLY>>(Signer::address_of(&signer)));
    }
}
// check: EXECUTED

//# run --signers FLYAdmin
script {
    use FLYAdmin::Config;
    use SwapAdmin::TokenSwap;
    use FLYAdmin::Initialize;
    use FLYAdmin::FLY::{FLY};
    use FaiAdmin::FAI::{FAI};

fun init_bond_stake(signer: signer) {
        Initialize::initialize_bond_stake(&signer);
        Config::update_bond_config<TokenSwap::LiquidityToken<FAI, FLY>>(
            &signer,
            1000u128,
            10000u128,
            100000000u128,
            1000000000000000000u128,
            10000000000000000u128,
            10000u128
        );
    }
}
// check: EXECUTED

//# run --signers alice
script {
    use FLYAdmin::Bond;
    use SwapAdmin::TokenSwap;
    use FLYAdmin::FLY::{FLY};
    use FaiAdmin::FAI::{FAI};

    fun deposit_stc_bond(signer: signer) {
        Bond::deposit<TokenSwap::LiquidityToken<FAI, FLY>>(&signer, 1000000u128, 152800000000000000u128);
    //        let bond_price = Bond::bond_price_usd<TokenSwap::LiquidityToken<FAI, FLY>>();
    //        StarcoinFramework::Debug::print(&bond_price);
    }
}
// check: EXECUTED

//# block --timestamp 1631254204293

//# run --signers alice
script {
    use FLYAdmin::Bond;
    use SwapAdmin::TokenSwap;
    use FLYAdmin::FLY::{FLY};
    use FaiAdmin::FAI::{FAI};

    fun redeem_lp_bond(signer: signer) {
        Bond::redeem<TokenSwap::LiquidityToken<FAI, FLY>>(&signer);
    }
}

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
    use FLYAdmin::Bond;
    use SwapAdmin::TokenSwap;
    use FLYAdmin::FLY::{FLY};
    use FaiAdmin::FAI::{FAI};

    fun deposit_stc_bond_expect_fail_global_switch_on(signer: signer) {
        Bond::deposit<TokenSwap::LiquidityToken<FAI, FLY>>(&signer, 1000000u128, 152800000000000000u128);
    }
}
// check: MoveAbort 52993

//# run --signers alice
script {
    use FLYAdmin::Bond;
    use SwapAdmin::TokenSwap;
    use FLYAdmin::FLY::{FLY};
    use FaiAdmin::FAI::{FAI};

    fun redeem_expect_fail_global_switch_on(signer: signer) {
        Bond::redeem<TokenSwap::LiquidityToken<FAI, FLY>>(&signer);
    }
}
// check: MoveAbort 52993
