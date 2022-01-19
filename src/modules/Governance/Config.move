address 0xA4c60527238c2893deAF3061B759c11E {
module Config {
    use 0x1::Config;
    use 0xA4c60527238c2893deAF3061B759c11E::Admin;

    struct BondConfig<TokenType> has copy, store, drop {
        control_var: u128,
        minimum_price: u128,
        max_payout: u128,
        fee: u128,
        max_debt: u128,
        vesting_term: u128
    }

    struct StakeConfig<TokenType> has copy, store, drop {
        reward_rate: u128,
        rebase_period: u64
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


}
}