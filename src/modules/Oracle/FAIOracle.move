address 0xC137657E5aeD5099592BA07c8ab44CC5 {
module FAIOracle {

    use 0xC137657E5aeD5099592BA07c8ab44CC5::Price ;

    public fun usdt_price(): Price::PriceNumber {
        Price::of(100,100)
    }
}
}
