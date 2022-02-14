address 0xA4c60527238c2893deAF3061B759c11E {
module Initialize {
    use 0x1::STC;
    use 0x1::Signer;
    use 0x1::PriceOracle;
    use 0x1::STCUSDOracle::{STCUSD};
    use 0xfe125d419811297dfab03c61efec0bc9::FAI;
    use 0xA4c60527238c2893deAF3061B759c11E::FLY;
    use 0xA4c60527238c2893deAF3061B759c11E::Bond;
    use 0xA4c60527238c2893deAF3061B759c11E::Stake;
    use 0xA4c60527238c2893deAF3061B759c11E::Config;
    use 0xA4c60527238c2893deAF3061B759c11E::Treasury;
    use 0x4783d08fb16990bd35d83f3e23bf93b8::TokenSwap;

    public fun initialize_bond_stake(sender: &signer) {
        initialize_bond(sender);
        initialize_config(sender);
        initialize_stake(sender);
    }

    public fun initialize_treasury(sender: &signer) {
        Treasury::initialize(sender, 10000000000000u128);
        Treasury::initialize_pool<STC::STC>(sender);
        Treasury::initialize_pool<FAI::FAI>(sender);
        Treasury::initialize_pool<TokenSwap::LiquidityToken<FLY::FLY, STC::STC>>(sender);
        Treasury::initialize_pool<TokenSwap::LiquidityToken<FAI::FAI, FLY::FLY>>(sender);
    }

    fun initialize_bond(sender: &signer) {
        Bond::initialize(sender);
        Bond::initialize_bond<FAI::FAI>(sender);
        Bond::initialize_bond<STC::STC>(sender);
        Bond::initialize_bond<TokenSwap::LiquidityToken<FLY::FLY, STC::STC>>(sender);
        Bond::initialize_bond<TokenSwap::LiquidityToken<FAI::FAI, FLY::FLY>>(sender);
    }

    fun initialize_stake(sender: &signer) {
        Stake::initialize(sender);
        Config::init_stake_config<FLY::FLY>(sender,
            100000000000000000u128,
            28800u64
        );
    }

    fun initialize_config(sender: &signer) {
        Config::init_bond_config<FAI::FAI>(sender,
            2500u128,
            1u128,
            10000000u128,
            1000000000000000000u128,
            10000000000000u128,
            432000u128
        );
        Config::init_bond_config<STC::STC>(sender,
            890u128,
            1u128,
            10000000u128,
            1000000000000000000u128,
            10000000000000u128,
            432000u128
        );
        Config::init_bond_config<TokenSwap::LiquidityToken<FLY::FLY, STC::STC>>(sender,
            8060u128,
            1u128,
            100000000u128,
            1000000000000000000u128,
            10000000000000u128,
            432000u128
        );
        Config::init_bond_config<TokenSwap::LiquidityToken<FAI::FAI, FLY::FLY>>(sender,
            205u128,
            1u128,
            100000000u128,
            1000000000000000000u128,
            10000000000000u128,
            432000u128
        );
    }

    public fun init_oracle(sender: &signer) {
        if (!PriceOracle::is_data_source_initialized<STCUSD>(Signer::address_of(sender))) {
            //STCUSDOracle::register(sender);
            PriceOracle::init_data_source<STCUSD>(sender, 152800);
        };
    }
}
}