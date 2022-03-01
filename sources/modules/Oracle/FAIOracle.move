address FLYAdmin {
module FAIOracle {

    use FLYAdmin::Price ;

    public fun usdt_price(): Price::PriceNumber {
        Price::of(100,100)
    }
}
}
