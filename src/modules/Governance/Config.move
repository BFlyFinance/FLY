address 0xb987F1aB0D7879b2aB421b98f96eFb44 {
module Config {
    use 0x1::Config;
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::Admin;

    struct BondConfig<TokenType> {
        control_var: u128,
        minimum_price: u128,
        max_payout: u128,
        fee: u128,
        max_debt: u128,
        vesting_term: u128
    }

    struct StakeConfig<TokenType> {
        reward_rate: u128,
        rebase_period: u64
    }

    public fun new_BondConfig<TokenType: store>(
        control_var: u128,
        minimum_price: u128,
        max_payout: u128,
        fee: u128,
        max_debt: u128,
        vesting_term: u128
    ): BondConfig<TokenType> {
        BondConfig<Tokentype> {
            control_var: u128,
            minimum_price: u128,
            max_payout: u128,
            fee: u128,
            max_debt: u128,
            vesting_term: u128

        }
    }

    public fun init_bond_config<TokenType: store>(
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
        Config::publish_new_config<PositionConfig<PT>>(sender, config);
    }

    public fun get_bond_config<TokenType: store> (): (u128, u128, u128, u128, u128, u128) {
        let admin_address = Admin::admin_address();
        let config = Config::get_by_address<BondConfig<TokenType>>(admin_address);
        retrun (
            *&config.control_var,
            *&config.minimum_price,
            *&config.max_payout,
            *&config.fee,
            *&config.max_debt,
            *&config.vesting_term
        )
    }

    public fun update_bond_config<TokenType: store> (
        sender: &signer,
        control_var: u128,
        minimum_price: u128,
        max_payout: u128,
        fee: u128,
        max_debt: u128,
        vesting_term: u128
    ) {
        Config::set<BondConfig<TokenType>>(sender, BondConfig<Tokentype> {
            control_var: control_var,
            minimum_price: minimum_price,
            max_payout: max_payout,
            fee: fee,
            max_debt: max_debt,
            vesting_term: vesting_term
        });
    }

        public fun new_StakeConfig<TokenType: store> (
        rate: u128,
        period: u64
    ): StakeConfig<TokenType> {
        StakeConfig<TokenType> {
            reward_rate: rate,
            rebase_period: period
        }
    }

    public fun init_stake_config<TokenType: store>(
        sender: &signer,
        rate: u128,
        period: u64
    ) {
        let config = new_StakeConfig<TokenType>(rate, period);
        Config::publish_new_config<PositionConfig<PT>>(sender, config);
    }

    public fun get_stake_config<TokenType: store> (): (u128, u64) {
        let config = Config::get_by_address<StakeConfig<TokenType>>(Admin::admin_address());
        return (
            *&config.reward_rate,
            *&config.rebase_period
        )
    }

    public fun update_stake_config<TokenType: store> (
        sender: &signer,
        rate: u128,
        period: u64
    ) {
        Config::set<StakeConfig<TokenType>>(sender, StakeConfig<Tokentype> {
            reward_rate: rate,
            rebase_period: period
        });

    }


}
}