address 0x7231Eb1A18d8711336B21f6106697253 {
module FAIMock {
    use 0x1::Token;
    use 0x1::Signer;
    use 0x1::Account;
    use 0x7231Eb1A18d8711336B21f6106697253::FAI::{Self, FAI};

    struct SharedMintCapability has key, store {
        cap: Token::MintCapability<FAI::FAI>,
    }

    struct SharedBurnCapability has key, store {
        cap: Token::BurnCapability<FAI::FAI>,
    }

    public fun initialize(account: &signer) {
        let (mint_cap, burn_cap) = FAI::initialize(account);
        let init_fai = mint_with_cap(100000000000000u128, &mint_cap);
        Account::deposit<FAI::FAI>(Signer::address_of(account), init_fai);
        move_to(account, SharedMintCapability{cap: mint_cap});
        move_to(account, SharedBurnCapability{cap: burn_cap});
    }

    public fun mint_with_cap(amount: u128, cap: &Token::MintCapability<FAI>): Token::Token<FAI> {
        Token::mint_with_capability<FAI>(
            cap,
            amount
        )
    }
}
}