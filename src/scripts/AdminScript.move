address 0xA4c60527238c2893deAF3061B759c11E {
module AdminScript {

    use 0xA4c60527238c2893deAF3061B759c11E::FLY;
    use 0xA4c60527238c2893deAF3061B759c11E::Config;
    use 0xA4c60527238c2893deAF3061B759c11E::Treasury;

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