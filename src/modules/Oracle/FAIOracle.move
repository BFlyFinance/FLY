address 0x7231Eb1A18d8711336B21f6106697253 {
module FAIOracle {

    use 0x7231Eb1A18d8711336B21f6106697253::Price ;

    public fun usdt_price(): Price::PriceNumber {
        Price::of(100,100)
    }
}
}
