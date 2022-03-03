address FLYAdmin {
module Admin {

    use StarcoinFramework::STC;
    use StarcoinFramework::Signer;
    use StarcoinFramework::ChainId;
    use StarcoinFramework::Token::{Self};
    use FLYAdmin::FLY;
    use FaiAdmin::FAI;
    use SwapAdmin::TokenSwap;

    const INVALID_ADDRESS: u64 = 1;
    const INVALID_TOKENTYPE: u64 = 2;

    public fun admin_address(): address {
        @FLYAdmin
    }

    public fun is_admin(sender: &signer) {
        assert!(Signer::address_of(sender) == @FLYAdmin, INVALID_ADDRESS );
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
            assert!(false, INVALID_TOKENTYPE);
            false
        }

    }
}
}