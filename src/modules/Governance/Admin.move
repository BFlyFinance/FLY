address 0xb987F1aB0D7879b2aB421b98f96eFb44 {
module Admin {

    use 0x1::STC;
    use 0x1::Signer;
    use 0x1::ChainId;
    use 0x1::Token::{Self};
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::FLY;
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::FAI;
    use 0x3db7a2da7444995338a2413b151ee437::TokenSwap;

    const INVALID_ADDRESS: u64 = 1;
    const INVALID_TOKENTYPE: u64 = 2;

    public fun admin_address(): address {
        @0xb987F1aB0D7879b2aB421b98f96eFb44
    }

    public fun is_admin(sender: &signer) {
        assert(Signer::address_of(sender) == @0xb987F1aB0D7879b2aB421b98f96eFb44, INVALID_ADDRESS );
    }

    public fun is_dev(): bool {
        let id = ChainId::get();
        id == 254 || id == 255
    }

    public fun is_main(): bool {
        let id = ChainId::get();
        id == 1
    }

    public fun is_barnard(): bool {
        let id = ChainId::get();
        id == 253
    }

    public fun is_reserve<TokenType: store>(): bool {
        if (Token::is_same_token<TokenType, STC::STC>()) {
            true
        } else if (Token::is_same_token<TokenType, FAI::FAI>()) {
            true
        } else if (Token::is_same_token<TokenType, TokenSwap::LiquidityToken<FLY::FLY, STC::STC>>()) {
            false
        } else if (Token::is_same_token<TokenType, TokenSwap::LiquidityToken<FLY::FLY, FAI::FAI>>()) {
            false
        } else {
            assert(false, INVALID_TOKENTYPE);
            false
        }

    }
}
}