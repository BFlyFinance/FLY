address 0xA4c60527238c2893deAF3061B759c11E {
module FAIOracle {

    use 0xA4c60527238c2893deAF3061B759c11E::Price ;

    public fun usdt_price(): Price::PriceNumber {
        Price::of(100,100)
    }
}
}
