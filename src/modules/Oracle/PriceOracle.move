address 0x164FbB953f822FBBA95d582B1794687C {
module PriceOracle {

    use 0x1::Token;
    use 0x1::STC;
    use 0x1::Errors;
    use 0x164FbB953f822FBBA95d582B1794687C::FAI;
    use 0x164FbB953f822FBBA95d582B1794687C::Price;
    use 0x164FbB953f822FBBA95d582B1794687C::Admin;
    use 0x164FbB953f822FBBA95d582B1794687C::STCOracle;
    use 0x164FbB953f822FBBA95d582B1794687C::FAIOracle;

    const NOT_SUPPROT_TOKEN_TYPE: u64 = 1;

    public fun usdt_price<TokenType: store>(): Price::PriceNumber {
        if (Token::is_same_token<TokenType, STC::STC>()) {
            return STCOracle::usdt_price()
        };
        if (Token::is_same_token<TokenType, FAI::FAI>()) {
            return FAIOracle::usdt_price()
        };
        if (!Admin::is_reserve<TokenType>()) {
            return Price::of(100, 100)
        };
        abort Errors::invalid_argument(NOT_SUPPROT_TOKEN_TYPE)
    }
}
}
