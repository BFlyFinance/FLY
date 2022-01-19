address 0xA4c60527238c2893deAF3061B759c11E {
module Treasury {

    use 0x1::Signer;
    use 0x1::Account;
    use 0x1::Token::{Self, Token};
    use 0xA4c60527238c2893deAF3061B759c11E::FLY;
    use 0xA4c60527238c2893deAF3061B759c11E::Admin;
    use 0xA4c60527238c2893deAF3061B759c11E::ExponentialU256;

    const INVALID_ADDRESS: u64 = 1;
    const INVALID_AMOUNT: u64 = 2;


    struct AssetPool<TokenType: copy+drop+store> has key, store {
        asset: Token<TokenType>
    }

    struct Dao has key, store {
        token: Token<FLY::FLY>
    }

    struct FLYMintCap has key, store {
        cap: Token::MintCapability<FLY::FLY>
    }

    struct FLYBurnCap has key, store {
        cap: Token::BurnCapability<FLY::FLY>
    }

    struct SharedMintCap has key, store {}


    public fun initialize(sender: &signer, amount: u128) {
        let (mint_cap, burn_cap) = FLY::initialize(sender);
        // ALERT: init mint
        let token = FLY::mint_with_cap(amount, &mint_cap);
        Account::deposit_to_self<FLY::FLY>(sender, token);
        move_to(sender, FLYMintCap {
            cap: mint_cap
        });
        move_to(sender, FLYBurnCap {
            cap: burn_cap
        });
        move_to(sender, AssetPool<FLY::FLY>{asset: Token::zero<FLY::FLY>()});
        move_to(sender, Dao{token: Token::zero<FLY::FLY>()});
    }

    public fun initialize_pool<TokenType: copy+drop+store>(sender: &signer) {
        Admin::is_admin(sender);
        move_to(sender, AssetPool<TokenType>{asset: Token::zero<TokenType>()});
    }

    public fun get_mint_cap(sender: &signer): SharedMintCap {
        Admin::is_admin(sender);
        SharedMintCap {}
    }

    public fun deposit<TokenType: copy+drop+store> (sender: &signer, amount: u128) acquires AssetPool {
        let balance = Account::balance<TokenType>(Signer::address_of(sender));
        assert(balance >= amount, INVALID_AMOUNT);
        let admin_address = Admin::admin_address();
        let pool = borrow_global_mut<AssetPool<TokenType>>(admin_address);
        let token = Account::withdraw<TokenType>(sender, amount);
        Token::deposit(&mut pool.asset, token);
    }

    public fun deposit_dao_fee_with_cap(amount: u128, cap: &SharedMintCap) acquires Dao, FLYMintCap {
       // mint fly then deposit to dao
        let _ = cap;
        let admin_address = Admin::admin_address();
        let dao = borrow_global_mut<Dao>(admin_address);
        let cap = borrow_global<FLYMintCap>(admin_address);
        let token = FLY::mint_with_cap(amount, &cap.cap);
        Token::deposit<FLY::FLY>(&mut dao.token, token);
    }

    public fun burn_dao(sender: &signer, amount: u128) acquires Dao, FLYBurnCap {
        let admin_address = Admin::admin_address();
        assert(admin_address == Signer::address_of(sender), INVALID_ADDRESS);
        let dao = borrow_global_mut<Dao>(admin_address);
        assert(Token::value<FLY::FLY>(&dao.token) >= amount, INVALID_AMOUNT);
        let token_to_burn = Token::withdraw<FLY::FLY>(&mut dao.token, amount);
        let fly_burn_cap = borrow_global<FLYBurnCap>(admin_address);
        FLY::burn_with_cap(token_to_burn, &fly_burn_cap.cap);
    }

    public fun withdraw_dao(sender: &signer, amount: u128) acquires Dao {
        let admin_address = Admin::admin_address();
        assert(admin_address == Signer::address_of(sender), INVALID_ADDRESS);
        let dao = borrow_global_mut<Dao>(admin_address);
        assert(Token::value<FLY::FLY>(&dao.token) >= amount, INVALID_AMOUNT);
        let token_to_withdraw = Token::withdraw<FLY::FLY>(&mut dao.token, amount);
        Account::deposit_to_self<FLY::FLY>(sender, token_to_withdraw);
    }

    public fun mint_reward_with_cap(reward_rate: u128, cap: &SharedMintCap): Token<FLY::FLY> acquires FLYMintCap {
        let _ = cap;
        let admin_address = Admin::admin_address();
        let cap = borrow_global<FLYMintCap>(admin_address);
        let total_fly = Token::market_cap<FLY::FLY>();
        let reward_rate_exp = ExponentialU256::exp_direct(reward_rate);
        let reward_exp = ExponentialU256::mul_exp(ExponentialU256::exp_direct(total_fly), reward_rate_exp);
        let reward = ExponentialU256::mantissa_to_u128(reward_exp);
        FLY::mint_with_cap(reward, &cap.cap)
    }

    public fun withdraw<TokenType: copy+drop+store>(sender: &signer, amount: u128) acquires AssetPool {
        Admin::is_admin(sender);
        let pool = borrow_global_mut<AssetPool<TokenType>>(Signer::address_of(sender));
        let balance = Token::value<TokenType>(&pool.asset);
        assert(balance >= amount, INVALID_AMOUNT);
        let token = Token::withdraw<TokenType>(&mut pool.asset, amount);
        Account::deposit_to_self<TokenType>(sender, token);
    }

    public fun mint_bond_token_with_cap(amount: u128, cap: &SharedMintCap): Token<FLY::FLY> acquires FLYMintCap {
        let _ = cap;
        let admin_address = Admin::admin_address();
        let cap = borrow_global<FLYMintCap>(admin_address);
        FLY::mint_with_cap(amount, &cap.cap)
    }


}
}