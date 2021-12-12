address 0xb987F1aB0D7879b2aB421b98f96eFb44 {
module Initialize {
    use 0x1::STC;
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::FAI;
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::FLY;
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::Bond;
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::Stake;
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::Config;
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::Treasury;
    use 0x3db7a2da7444995338a2413b151ee437::TokenSwap;

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
    }

    fun initialize_config(sender: &signer) {
        Config::init_bond_config<FAI::FAI>(sender, 2500u128, 1u128, 10000000u128, 1000000000000000000u128, 10000000000000u128, 100000000u128);
        Config::init_bond_config<STC::STC>(sender, 890u128, 1u128, 10000000u128, 1000000000000000000u128, 10000000000000u128, 100000000u128);
        Config::init_bond_config<TokenSwap::LiquidityToken<FLY::FLY, STC::STC>>(sender, 8060u128, 1u128, 100000000u128, 1000000000000000000u128, 10000000000000u128, 100000000u128);
        Config::init_bond_config<TokenSwap::LiquidityToken<FLY::FLY, FAI::FAI>>(sender, 205u128, 1u128, 100000000u128, 1000000000000000000u128, 10000000000000u128, 100000000u128);
    }

}
}