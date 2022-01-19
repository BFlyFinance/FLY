address 0xA4c60527238c2893deAF3061B759c11E {
module Admin {

    use 0x1::STC;
    use 0x1::Signer;
    use 0x1::ChainId;
    use 0x1::Token::{Self};
    use 0xA4c60527238c2893deAF3061B759c11E::FLY;
    use 0xfe125d419811297dfab03c61efec0bc9::FAI;
    use 0x4783d08fb16990bd35d83f3e23bf93b8::TokenSwap;

    const INVALID_ADDRESS: u64 = 1;
    const INVALID_TOKENTYPE: u64 = 2;

    public fun admin_address(): address {
        @0xA4c60527238c2893deAF3061B759c11E
    }

    public fun is_admin(sender: &signer) {
        assert(Signer::address_of(sender) == @0xA4c60527238c2893deAF3061B759c11E, INVALID_ADDRESS );
    }

    public fun is_dev(): bool {
        let id = ChainId::get();
        id == 252 || id == 254 || id == 255
    }

    public fun is_main(): bool {
        let id = ChainId::get();
        id == 1
    }

    public fun is_barnard(): bool {
        let id = ChainId::get();
        id == 251
    }

    public fun is_reserve<TokenType: store>(): bool {
        if (Token::is_same_token<TokenType, STC::STC>()) {
            true
        } else if (Token::is_same_token<TokenType, FAI::FAI>()) {
            true
        } else if (Token::is_same_token<TokenType, TokenSwap::LiquidityToken<FLY::FLY, STC::STC>>()) {
            false
        } else if (Token::is_same_token<TokenType, TokenSwap::LiquidityToken<FAI::FAI, FLY::FLY>>()) {
            false
        } else {
            assert(false, INVALID_TOKENTYPE);
            false
        }

    }
}
}