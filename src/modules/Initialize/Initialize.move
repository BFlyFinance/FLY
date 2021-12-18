address 0xC137657E5aeD5099592BA07c8ab44CC5 {
module Initialize {
    use 0x1::STC;
    use 0xC137657E5aeD5099592BA07c8ab44CC5::FAI;
    use 0xC137657E5aeD5099592BA07c8ab44CC5::FLY;
    use 0xC137657E5aeD5099592BA07c8ab44CC5::Bond;
    use 0xC137657E5aeD5099592BA07c8ab44CC5::Stake;
    use 0xC137657E5aeD5099592BA07c8ab44CC5::Config;
    use 0xC137657E5aeD5099592BA07c8ab44CC5::Treasury;
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
        Treasury::initialize_pool<TokenSwap::LiquidityToken<FLY::FLY, FAI::FAI>>(sender);

    }

    fun initialize_bond(sender: &signer) {
        Bond::initialize(sender);
        Bond::initialize_bond<FAI::FAI>(sender);
        Bond::initialize_bond<STC::STC>(sender);
        Bond::initialize_bond<TokenSwap::LiquidityToken<FLY::FLY, STC::STC>>(sender);
        Bond::initialize_bond<TokenSwap::LiquidityToken<FLY::FLY, FAI::FAI>>(sender);
    }

    fun initialize_stake(sender: &signer) {
        Stake::initialize(sender);
        Config::init_stake_config<FLY::FLY>(sender, 1000000000000000000u128, 432000u64);
    }

    fun initialize_config(sender: &signer) {
        Config::init_bond_config<FAI::FAI>(sender, 2500u128, 1u128, 10000000u128, 1000000000000000000u128, 10000000000000u128, 100000000u128);
        Config::init_bond_config<STC::STC>(sender, 890u128, 1u128, 10000000u128, 1000000000000000000u128, 10000000000000u128, 100000000u128);
        Config::init_bond_config<TokenSwap::LiquidityToken<FLY::FLY, STC::STC>>(sender, 8060u128, 1u128, 100000000u128, 1000000000000000000u128, 10000000000000u128, 100000000u128);
        Config::init_bond_config<TokenSwap::LiquidityToken<FLY::FLY, FAI::FAI>>(sender, 205u128, 1u128, 100000000u128, 1000000000000000000u128, 10000000000000u128, 100000000u128);
    }

}
}