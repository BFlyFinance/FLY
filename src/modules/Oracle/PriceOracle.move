address 0xC137657E5aeD5099592BA07c8ab44CC5 {
module PriceOracle {

    use 0x1::Token;
    use 0x1::STC;
    use 0x1::Errors;
    use 0xC137657E5aeD5099592BA07c8ab44CC5::FAI ;
    use 0xC137657E5aeD5099592BA07c8ab44CC5::STCOracle;
    use 0xC137657E5aeD5099592BA07c8ab44CC5::FAIOracle;
    use 0xC137657E5aeD5099592BA07c8ab44CC5::Price ;

    const NOT_SUPPROT_TOKEN_TYPE: u64 = 1;


    public fun usdt_price<TokenType: store>(): Price::PriceNumber {
        if (Token::is_same_token<TokenType, STC::STC>()) {
            return STCOracle::usdt_price()
        };
        if (Token::is_same_token<TokenType, FAI::FAI>()) {
            return FAIOracle::usdt_price()
        };
        abort Errors::invalid_argument(NOT_SUPPROT_TOKEN_TYPE)
    }
}
}
