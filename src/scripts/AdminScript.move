address 0x7231Eb1A18d8711336B21f6106697253 {
module AdminScript {

    use 0x7231Eb1A18d8711336B21f6106697253::FLY;
    use 0x7231Eb1A18d8711336B21f6106697253::Config;
    use 0x7231Eb1A18d8711336B21f6106697253::Treasury;

    public(script) fun update_bond_config<TokenType: store+drop+copy>(account: signer,
        control_var: u128,
        minimum_price: u128,
        max_payout: u128,
        fee: u128,
        max_debt: u128,
        vesting_term: u128
    ) {
        Config::update_bond_config<TokenType>(&account,
            control_var,
            minimum_price,
            max_payout,
            fee,
            max_debt,
            vesting_term
        );
    }

    public(script) fun update_stake_config(account: signer,
       rate: u128,
       period: u64
    ) {
        Config::update_stake_config<FLY::FLY>(&account,
            rate,
            period
        );
    }

    public(script) fun burn_dao(account: signer, amount: u128) {
        Treasury::burn_dao(&account, amount);
    }

    public(script) fun withdraw_dao(account: signer, amount: u128) {
        Treasury::withdraw_dao(&account, amount);
    }

    public(script) fun withdraw_asset<TokenType: store+drop+copy>(account: signer, amount: u128) {
        Treasury::withdraw<TokenType>(&account, amount);
    }
}
}