address 0xb987F1aB0D7879b2aB421b98f96eFb44 {
module Stake {

    use 0x1::Token;
    use 0x1::Signer;
    use 0x1::Account;
    use 0x1::Timestamp;
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::FLY;
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::Admin;
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::Config;
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::Treasury;

    const INSUFFICIENT_AMOUNT: u64 = 1;

    struct Pool<TokenType> has key, store {
        token: Token<TokenType>,
        index: u128,
        last_update_time: u64
    }

    struct sFLY has key, store {
        amount: u128,
        warmup_amount: u128,
        warmup_expires: u64,
        index: u128,
        index_last_update: u64
    }

    struct warmup<TokenType> has key, store {
        token: Token<TokenType>,
        expires: u64
    }

    struct MintCap has key, store {
        cap: Treasury::SharedMintCap
    }

    fun init_sfly(sender: &signer) {
        let address = Signer::address_of(sender);
        if (!exists<sFLY>(address)) {
            move_to(sender, sFLY{
                amount: 0u128,
                warmup_amount: 0128,
                warmup_expires: 0u64,
                index: 1u128,
                index_last_update: 0u64
            });
        }
    }

    // retrieve fly from warmup
    public fun claim() acquires warmup, Pool {
        let time_now = Timestamp::now_milliseconds();
        let admin_address = Admin::admin_address();
        let warmup = borrow_global_mut<warmup<FLY>>(admin_address);
        let pool = borrow_global_mue<Pool<FLY>>(admin_address);
        if (warmup.warmup_expires <= time_now) {
            rebase<FLY::FLY>();
            // retrieve FLY into Pool
            let (_, rabse_period) = Config::get_stake_config<TokenType>();
            let balance = Token::value(warmup.token);
            let token = Token::withdraw(&mut warmup.token, balance);
            Token::deposit(&mut pool.token, token);
            // set next expires
            warmup.expires = warmup.expires + rebase_period;
        };
    }

    // forfeit sFLY in warmup and retrieve FLY
    public fun forfeit(sender: &signer) acquires SFLY, warmup {
        rebase();
        claim();
        let admin_address = Admin::admin_address();
        let address = Signer::address_of(sender);
        let sFLY = borrow_global_mut<sFLY>(address);
        let time_now = Timestamp::now_milliseconds();
        if (sFLY.warmup_amount > 0 && warmup_expires < time_now) {
            let warmup = borrow_global_mut<warmup>(admin_address);
            // send FLY to sender
            let token = Token::withdraw(&mut warmup.token, sFLY.warmup_amount);
            Token::deposit<FLY::FLY>(sender, token);
            sFLY.warmup_amount = 0u128;
            sFLY.warmup_expires = 0u64;
        };
    }

    public fun stake<TokenType>(sender: &signer, amount: u128)acquires warmup, sFLY {
        rebase();
        claim();
        // check sender have enough amount
        let admin_address = Admin::admin_address();
        let balance = Account::balance<TokenType>(Signer::address_of(sender));
        assert(balance >= amount, INSUFFICIENT_AMOUNT);
        let warmup = borrow_global_mut<warmup<TokenType>>(admin_address);
        Token::deposit<TokenType>(&mut warmup.token, token);
        init_sfly(sender);
        let sFLY = borrow_global_mut<sFLY>(Signer::address_of(sender));
        sFLY.warmup_amount = amount;
        // set warmup expires
        sFLY.warmup_expires = warmup.expires;

    }

    public fun unstake<TokenType>(sender: &signer, amount: u128) acquires Pool, sFLY{
        rebase();
        claim();
        fresh<TokenType>(Signer::address_of(sender));
        let sFLY = borrow_global_mut<sFLY>(Signer::address_of(sender));
        assert(amount <= sFLY.amount, INSUFFICIENT_AMOUNT);
        sFLY.amount = sFLY.amount - amount;
        let Pool = borrow_global_mut<Pool<TokenType>>(Admin::admin_address());
        let tokens = Token::withdraw<TokenType>(&mut Pool.token, amount);
        Account::deposit_to_self<TokenType>(sender, tokens);
    }

    fun fresh<TokenType>(address: address) acquires Pool, sFLY {
        let Pool = borrow_global<Pool<TokenType>>(Admin::admin_address());
        let pool_index = *&Pool.index;
        let sFLY = borrow_global_mut<sFLY>(copy address);
        let user_index = *&sFLY.index;
        let amount = *&sFLY.amount;
        let reward = TreasuryHelper::reward(pool_index, user_index, amount);
        sFLY.amount = sFLY.amount + reward;
        sFLY.index = pool_index;
        sFLY.index_last_update = Timestamp::now_milliseconds();
    }

    public fun rebase<TokenType>() acquires Pool, MintCap {
        let time_now = Timestamp::now_milliseconds();
        let Pool = borrow_global<Pool<TokenType>>(Admin::address_of());
        let (reward_rate, rabse_period) = Config::get_stake_config<TokenType>();
        let next_rebase_at = Pool.last_update_time + rebase_period;
        if (next_rebase_at <= time_now) {
            // mint reward fly into Pool
            let admin_address = Admin::admin_address();
            let mint_cap = borrow_global<MintCap>(admin_address);
            let token = Treasury::mint_reward_with_cap(reward_rate, mint_cap.cap);
            let reward_amount = Token::value<FLY>(token);
            let stake_amount = Token::value<FLY>(Pool.token);
            // rebase index
            let new_index = TreasuryHelper::new_index(old_index, amount, stake_amount);
            Pool.index = new_index;
            // update next rebase time
            Pool.next_rebase_at = Pool.next_rebase_at + rebase_period;
            Token::deposit(&mut Pool.token, token);
        };
        claim();
    }

    public fun index<TokenType>(): u128 acquires Pool {
        let Pool = borrow_global<Pool<TokenType>>(Admin::address_of());
        Pool.index
    }
}
}