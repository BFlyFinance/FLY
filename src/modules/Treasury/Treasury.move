address 0xb987F1aB0D7879b2aB421b98f96eFb44 {
module Treasury {

    use 0x1::Token;
    use 0x1::Signer;
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::FLY;
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::Admin;

    const INVALID_ADDRESS: u64 = 1;
    const INVALID_AMOUNT: u64 = 2;


    struct AssetPool<TokenType> has key, store {
        asset: Token<TokenType>
    }

    struct Dao<TokenType> has key, store {
        token: Token<TokenType>
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

    public fun deposit<TokenType> (sender: &signer, amount: u128) acquires AssetPool {
        let balance = Account::balance<TokenType>(Signer::address_of(sender));
        assert(balance >= amount, INVALID_AMOUNT);
        let admin_address = Admin::admin_address();
        let pool = borrow_global_mut<AssetPool<TokenType>>(admin_address);
        let token = Account::withdraw<Token>(sender, amount);
        Token::deposit(&mut pool.asset, token);
    }

    public fun deposit_dao_fee_with_cap(amount: u128, cap: &SharedMintCap) acquires Dao, FLYMintCap {
       // mint fly then deposit to dao
        let admin_address = Admin::admin_address();
        let dao = borrow_global_mut<Dao<FLY::FLY>>(admin_address);
        let cap = borrow_global<FLYMintCap>(admin_address);
        let token = FLY::mint_with_cap(amount, cap.cap);
        Token::deposit<FLY::FLY>(&mut dao.token, token);
    }

    public fun burn_dao<TokenType>(sender: &signer, amount: u128) acquires Dao, FLYBurnCap {
        let admin_address = Admin::admin_address();
        assert(admin_address == Signer::address_of(sender), INVALID_ADDRESS);
        let dao = borrow_global_mut<Dao<TokenType>>(admin_address);
        assert(Token::value<TokenType>(dao.token) >= amount, INVALID_AMOUNT);
        let token_to_burn = Token::withdraw<TokenType>(&mut dao.token, amount);
        let fly_burn_cap = borrow_global<FLYBurnCap>(admin_address);
        FLY::burn_with_capability(token_to_burn, fly_burn_cap.cap);
    }

    public fun mint_reward_with_cap(reward_rate: u128, cap: &SharedMintCap): Token<FLY> acquires FLYMintCap {
        let admin_address = Admin::admin_address();
        let cap = borrow_global<FLYMintCap>(admin_address);
        let total_fly = Token::market_cap<FLY::FLY>();
        // TODO: calc
        let reward = total_fly * reward_rate;
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