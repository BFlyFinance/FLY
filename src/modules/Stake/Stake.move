address 0xA4c60527238c2893deAF3061B759c11E {
module Stake {

    use 0x1::Token;
    use 0x1::Signer;
    use 0x1::Account;
    use 0x1::Timestamp;
    use 0xA4c60527238c2893deAF3061B759c11E::FLY;
    use 0xA4c60527238c2893deAF3061B759c11E::Admin;
    use 0xA4c60527238c2893deAF3061B759c11E::Config;
    use 0xA4c60527238c2893deAF3061B759c11E::Treasury;
    use 0xA4c60527238c2893deAF3061B759c11E::TreasuryHelper;
    use 0xA4c60527238c2893deAF3061B759c11E::ExponentialU256;

    const INSUFFICIENT_AMOUNT: u64 = 1;

    struct Pool has key, store {
        token: Token::Token<FLY::FLY>,
        index: u128,
        last_update_time: u64
    }

    struct SFLY has key, store {
        amount: u128,
        warmup_amount: u128,
        warmup_expires: u64,
        index: u128,
        index_last_update: u64
    }

    struct Warmup has key, store {
        token: Token::Token<FLY::FLY>,
        expires: u64
    }

    struct MintCap has key, store {
        cap: Treasury::SharedMintCap
    }

    public fun initialize(sender: &signer) {
        Admin::is_admin(sender);  
        move_to(sender, Pool {
            token: Token::zero<FLY::FLY>(),
            index: 1000000000000000000u128,
            last_update_time: Timestamp::now_seconds()
        });
        let mint_cap = Treasury::get_mint_cap(sender);
        move_to(sender, MintCap {cap: mint_cap});
        move_to(sender, Warmup {token: Token::zero<FLY::FLY>(), expires: Timestamp::now_seconds()});

    }

    fun init_sfly(sender: &signer) acquires Pool {
        let address = Signer::address_of(sender);
        let admin_address = Admin::admin_address();
        let pool = borrow_global<Pool>(admin_address);
        if (!exists<SFLY>(address)) {
            move_to(sender, SFLY{
                amount: 0u128,
                warmup_amount: 0u128,
                warmup_expires: 0u64,
                index: *&pool.index,
                index_last_update: 0u64
            });
        }
    }

    // retrieve fly from warmup
    public fun claim() acquires Warmup, Pool{
        let time_now = Timestamp::now_seconds();
        let admin_address = Admin::admin_address();
        let warmup = borrow_global<Warmup>(admin_address);
        if (warmup.expires <= time_now) {
            // retrieve FLY into Pool
            let warmup = borrow_global_mut<Warmup>(admin_address);
            let pool = borrow_global_mut<Pool>(admin_address);
            let (_, rebase_period) = Config::get_stake_config<FLY::FLY>();
            let balance = Token::value<FLY::FLY>(&warmup.token);
            let token = Token::withdraw<FLY::FLY>(&mut warmup.token, balance);
            Token::deposit<FLY::FLY>(&mut pool.token, token);
            // set next expires
            warmup.expires = warmup.expires + rebase_period;
        };
    }

    // forfeit sFLY in warmup and retrieve FLY
    public fun forfeit(sender: &signer) acquires SFLY, Warmup, Pool, MintCap {
        rebase();
        claim();
        fresh(Signer::address_of(sender));
        let admin_address = Admin::admin_address();
        let address = Signer::address_of(sender);
        let s_fly = borrow_global_mut<SFLY>(address);
        let time_now = Timestamp::now_seconds();
        if (s_fly.warmup_amount > 0 && s_fly.warmup_expires > time_now) {
            let warmup = borrow_global_mut<Warmup>(admin_address);
            // send FLY to sender
            let token = Token::withdraw(&mut warmup.token, s_fly.warmup_amount);
            Account::deposit_to_self<FLY::FLY>(sender, token);
            s_fly.warmup_amount = 0u128;
            s_fly.warmup_expires = 0u64;
        };
    }

    public fun stake(sender: &signer, amount: u128) acquires Warmup, SFLY, Pool, MintCap {
        rebase();
        claim();
        // check sender have enough amount
        let admin_address = Admin::admin_address();
        let balance = Account::balance<FLY::FLY>(Signer::address_of(sender));
        assert(balance >= amount, INSUFFICIENT_AMOUNT);
        let token = Account::withdraw<FLY::FLY>(sender, amount);
        let warmup = borrow_global_mut<Warmup>(admin_address);
        Token::deposit<FLY::FLY>(&mut warmup.token, token);
        init_sfly(sender);
        fresh(Signer::address_of(sender));
        let s_fly = borrow_global_mut<SFLY>(Signer::address_of(sender));
        s_fly.warmup_amount = s_fly.warmup_amount + amount;
        // set warmup expires
        s_fly.warmup_expires = warmup.expires;
    }

    public fun unstake(sender: &signer, amount: u128) acquires Pool, SFLY, Warmup, MintCap{
        rebase();
        claim();
        fresh(Signer::address_of(sender));
        let s_fly = borrow_global_mut<SFLY>(Signer::address_of(sender));
        assert(amount <= s_fly.amount, INSUFFICIENT_AMOUNT);
        s_fly.amount = s_fly.amount - amount;
        let pool = borrow_global_mut<Pool>(Admin::admin_address());
        let tokens = Token::withdraw<FLY::FLY>(&mut pool.token, amount);
        Account::deposit_to_self<FLY::FLY>(sender, tokens);
    }

    fun fresh(address: address) acquires Pool, SFLY {
        let pool = borrow_global<Pool>(Admin::admin_address());
        let pool_index = *&pool.index;
        let s_fly = borrow_global_mut<SFLY>(copy address);
        let time_now = Timestamp::now_seconds();
        if (time_now >= s_fly.warmup_expires) {
            s_fly.amount = s_fly.amount + s_fly.warmup_amount;
            s_fly.warmup_amount = 0;
        };
        let user_index = *&s_fly.index;
        if (user_index != pool_index) {
            let amount = *&s_fly.amount;
            let reward = TreasuryHelper::reward(pool_index, user_index, amount);
            s_fly.amount = s_fly.amount + reward;
            s_fly.index = pool_index;
            s_fly.index_last_update = Timestamp::now_seconds();
        };
    }

    public fun rebase() acquires Pool, MintCap, Warmup {
        let time_now = Timestamp::now_seconds();
        let pool = borrow_global_mut<Pool>(Admin::admin_address());
        let stake_amount = Token::value<FLY::FLY>(&pool.token);
        let (reward_rate, rebase_period) = Config::get_stake_config<FLY::FLY>();
        let next_rebase_at = pool.last_update_time + rebase_period;
        if (stake_amount != 0 && next_rebase_at <= time_now) {
            // mint reward fly into Pool
            let admin_address = Admin::admin_address();
            let mint_cap = borrow_global<MintCap>(admin_address);
            let token = Treasury::mint_reward_with_cap(reward_rate, &mint_cap.cap);
            let reward_amount = Token::value<FLY::FLY>(&token);
            // rebase index
            let new_index = TreasuryHelper::new_index(pool.index, reward_amount, stake_amount);
            pool.index = new_index;
            // update next rebase time
            pool.last_update_time = pool.last_update_time + rebase_period;
            Token::deposit<FLY::FLY>(&mut pool.token, token);
        };
        claim();
    }

    public fun index(): u128 acquires Pool {
        let pool = borrow_global<Pool>(Admin::admin_address());
        pool.index
    }

    public fun next_reward_ratio(): u128 acquires Pool {
//        let time_now = Timestamp::now_seconds();
        let pool = borrow_global_mut<Pool>(Admin::admin_address());
        let stake_amount = Token::value<FLY::FLY>(&pool.token);
        let (reward_rate, _) = Config::get_stake_config<FLY::FLY>();
        if (stake_amount == 0u128) {
            return 0u128
        };
        let reward_amount_exp = TreasuryHelper::next_reward_exp(reward_rate);
        let next_reward_ratio_exp = ExponentialU256::div_exp(reward_amount_exp, ExponentialU256::exp_direct(stake_amount));
        ExponentialU256::mantissa_to_u128(next_reward_ratio_exp)
    }
}
}