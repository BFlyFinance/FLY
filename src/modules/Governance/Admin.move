address 0xb987F1aB0D7879b2aB421b98f96eFb44 {
module Admin {

    use 0x1::Token::{Self, TokenCode};

    const INVALID_ADDRESS: u64 = 1;

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
        if (Token::is_same_token<TokenType, FLY>()) {
            true
        } else if (Token::is_same_token<TokenType, FAI>()) {
            true
        } else if (Token::is_same_token<TokenType, LP>()) {
            false
        }
    }
}
}