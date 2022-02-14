address 0xA4c60527238c2893deAF3061B759c11E {
module PriceOracle {

    use 0x1::Token;
    use 0x1::STC;
    use 0x1::Errors;
    use 0xA4c60527238c2893deAF3061B759c11E::Price;
    use 0xA4c60527238c2893deAF3061B759c11E::Admin;
    use 0xA4c60527238c2893deAF3061B759c11E::STCOracle;
    use 0xA4c60527238c2893deAF3061B759c11E::FAIOracle;
    use 0xfe125d419811297dfab03c61efec0bc9::FAI;

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
