address FLYAdmin {
module Config {
    use StarcoinFramework::Config;
    use StarcoinFramework::Signer;
    use StarcoinFramework::Errors;
    use FLYAdmin::Admin;

    const DEFAULT_GLOBAL_SWITCH: bool = false;
    const GLOBAL_SWITCH_OFF: u64 = 207;

    struct BondConfig<phantom TokenType> has copy, store, drop {
        control_var: u128,
        minimum_price: u128,
        max_payout: u128,
        fee: u128,
        max_debt: u128,
        vesting_term: u128
    }

    struct StakeConfig<phantom TokenType> has copy, store, drop {
        reward_rate: u128,
        rebase_period: u64
    }

    struct GlobalSwitch has copy, drop, store {
        switch: bool
    }

    public fun new_BondConfig<TokenType: copy+drop+store>(
        control_var: u128,
        minimum_price: u128,
        max_payout: u128,
        fee: u128,
        max_debt: u128,
        vesting_term: u128
    ): BondConfig<TokenType> {
        BondConfig<TokenType> {
            control_var: control_var,
            minimum_price: minimum_price,
            max_payout: max_payout,
            fee: fee,
            max_debt: max_debt,
            vesting_term: vesting_term

        }
    }

    public fun init_bond_config<TokenType: copy+drop+store>(
        sender: &signer,
        control_var: u128,
        minimum_price: u128,
        max_payout: u128,
        fee: u128,
        max_debt: u128,
        vesting_term: u128
    ) {
        let config = new_BondConfig<TokenType>(
            control_var,
            minimum_price,
            max_payout,
            fee,
            max_debt,
            vesting_term
        );
        Config::publish_new_config<BondConfig<TokenType>>(sender, config);
    }

    public fun get_bond_config<TokenType: copy+drop+store> (): (u128, u128, u128, u128, u128, u128) {
        let admin_address = Admin::admin_address();
        let config = Config::get_by_address<BondConfig<TokenType>>(admin_address);
        return (
            *&config.control_var,
            *&config.minimum_price,
            *&config.max_payout,
            *&config.fee,
            *&config.max_debt,
            *&config.vesting_term
        )
    }

    public fun update_bond_config<TokenType: copy+drop+store> (
        sender: &signer,
        control_var: u128,
        minimum_price: u128,
        max_payout: u128,
        fee: u128,
        max_debt: u128,
        vesting_term: u128
    ) {
        Config::set<BondConfig<TokenType>>(sender, BondConfig<TokenType> {
            control_var: control_var,
            minimum_price: minimum_price,
            max_payout: max_payout,
            fee: fee,
            max_debt: max_debt,
            vesting_term: vesting_term
        });
    }

        public fun new_StakeConfig<TokenType: copy+drop+store> (
        rate: u128,
        period: u64
    ): StakeConfig<TokenType> {
        StakeConfig<TokenType> {
            reward_rate: rate,
            rebase_period: period
        }
    }

    public fun init_stake_config<TokenType: copy+drop+store>(
        sender: &signer,
        rate: u128,
        period: u64
    ) {
        let config = new_StakeConfig<TokenType>(rate, period);
        Config::publish_new_config<StakeConfig<TokenType>>(sender, config);
    }

    public fun get_stake_config<TokenType: copy+drop+store> (): (u128, u64) {
        let config = Config::get_by_address<StakeConfig<TokenType>>(Admin::admin_address());
        return (
            *&config.reward_rate,
            *&config.rebase_period
        )
    }

    public fun update_stake_config<TokenType: copy+drop+store> (
        sender: &signer,
        rate: u128,
        period: u64
    ) {
        Config::set<StakeConfig<TokenType>>(sender, StakeConfig<TokenType> {
            reward_rate: rate,
            rebase_period: period
        });

    }

    public fun set_global_switch(signer: &signer, switch: bool) {
        Admin::is_admin(signer);
        let config = GlobalSwitch {
            switch
        };
        if (Config::config_exist_by_address<GlobalSwitch>(Signer::address_of(signer))) {
            Config::set<GlobalSwitch>(signer, config);
        } else {
            Config::publish_new_config<GlobalSwitch>(signer, config);
        }
    }

    public fun get_global_switch(): bool {
        if (Config::config_exist_by_address<GlobalSwitch>(Admin::admin_address())) {
            let switch_config = Config::get_by_address<GlobalSwitch>(Admin::admin_address());
            switch_config.switch
        } else {
            DEFAULT_GLOBAL_SWITCH
        }
    }

    public fun check_global_switch() {
        assert!(!get_global_switch(), Errors::invalid_state(GLOBAL_SWITCH_OFF));
    }
}
}