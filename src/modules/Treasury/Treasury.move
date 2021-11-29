address 0xb987F1aB0D7879b2aB421b98f96eFb44 {
module Treasury {

    use 0x1::Token;
    use 0x1::Signer;
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::FLY;
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::Admin;

    const INVALID_ADDRESS: u64 = 1;


    struct AssetPool<TokenType> has key, store {
        asset: TokenType
    }

    struct Dao<TokenType> has key, store {
        token: TokenType
    }

    struct FLYMintCap has key, store {
        cap: Token::MintCapability<FLY::FLY>
    }

    struct FLYBurnCap has key, store {
        cap: Token::BurnCapability<FLY::FLY>
    }

    struct SharedMintCap has key, store {}


    public fun initialize(sender: &signer) {
        let (mint_cap, burn_cap) = FLY::initialize(sender);
        move_to(sender, FLYMintCap {
            cap: mint_cap
        });
        move_to(sender, FLYBurnCap {
            cap: burn_cap
        });
        // init pools for support asset
    }

    public fun get_mint_cap(sender: &signer): SharedMintCap {
        Admin::is_admin(sender);
        SharedMintCap {}
    }

    public fun deposit<TokenType> (sender: &signer, amount: u128) {

    }

    public fun deposit_dao_fee_with_cap(amount: u128, cap: &SharedMintCap) {
       // mint fly then deposit to dao
    }

    public fun burn_dao(sender: &signer, amount: u128) {

    }

    public fun mint_fly_with_cap(amount: u128, cap: &SharedMintCap): Token<FLY> acquires FLYMintCap {
        let admin_address = Admin::admin_address();
        let cap = borrow_global<FLYMintCap>(admin_address);
        // mint fly with cap
        FLY::mint_with_cap(amount, &cap.cap)
    }

    public fun withdraw<TokenType>(sender: &signer, amount: u128) {
        let admin_address = Admin::admin_address();
        let sender_address = Signer::address_of(sender);
        assert(admin_address == sender_address, INVALID_ADDRESS);

    }


}
}