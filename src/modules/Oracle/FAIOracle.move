address 0x164FbB953f822FBBA95d582B1794687C {
module FAIOracle {

    use 0x164FbB953f822FBBA95d582B1794687C::Price ;

    public fun usdt_price(): Price::PriceNumber {
        Price::of(100,100)
    }
}
}
