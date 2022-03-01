address FLYAdmin {
module STCOracle {

    use StarcoinFramework::STC::STC;
    use StarcoinFramework::STCUSDOracle::{STCUSD};
    use StarcoinFramework::PriceOracle;
    use FLYAdmin::Price ;
    use FLYAdmin::Admin ;
    use FLYAdmin::ExponentialU256::{Self, Exp};
    //0.2
    public fun usdt_price(): Price::PriceNumber {
        let oracle_address = oracle_address<STC>();
        let (exp, scaling_factor) = usd_price<STCUSD>(oracle_address);
        Price::of(ExponentialU256::mantissa_to_u128(exp), scaling_factor)
    }

    fun usd_price<OracleType: store + drop + copy>
    (oracle_address: address): (Exp, u128) {
        let price = PriceOracle::read<OracleType>(oracle_address);
        let scaling_factor = PriceOracle::get_scaling_factor<OracleType>();
        let exp = ExponentialU256::exp_direct(price);
        (exp, scaling_factor)
    }

    fun oracle_address<TokenType: store>(): address {
        if (Admin::is_barnard()) {
            return @0x07fa08a855753f0ff7292fdcbe871216
        } else if(Admin::is_main()) {
            return @0x82e35b34096f32c42061717c06e44a59
        };
        return @FLYAdmin
    }
}
}

