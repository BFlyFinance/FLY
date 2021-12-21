address 0xC137657E5aeD5099592BA07c8ab44CC5 {
module Price {

    struct PriceNumber has drop,copy{
        value: u128,
        scaling_factor: u128
    }

    public fun of(value: u128, dec: u128): PriceNumber {
        PriceNumber {
            value: value,
            scaling_factor: dec
        }
    }

    public fun unpack(v: PriceNumber): (u128, u128) {
        (v.value, v.scaling_factor)
    }
}
}
