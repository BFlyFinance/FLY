address 0x7231Eb1A18d8711336B21f6106697253 {
module STCOracle {

    use 0x1::STC::STC;
    use 0x1::STCUSDOracle::{STCUSD};
    use 0x1::PriceOracle;
    use 0x7231Eb1A18d8711336B21f6106697253::Price ;
    use 0x7231Eb1A18d8711336B21f6106697253::Admin ;
    use 0x7231Eb1A18d8711336B21f6106697253::ExponentialU256::{Self, Exp};
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
        return @0x7231Eb1A18d8711336B21f6106697253
    }
}
}

