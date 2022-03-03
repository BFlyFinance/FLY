address FLYAdmin {
module TreasuryHelper{

    use StarcoinFramework::STC;
    use StarcoinFramework::Math;
    use StarcoinFramework::Token;
    use FLYAdmin::FLY;
    use FaiAdmin::FAI;
    use FLYAdmin::Admin;
    use FLYAdmin::ExponentialU256::{Self, Exp};
    use SwapAdmin::TokenSwap::{Self};

    public fun value_of<TokenType: drop+copy+store> (amount: u128): u128 {
        if (Admin::is_reserve<TokenType>()) {
            amount * Token::scaling_factor<FLY::FLY>() / Token::scaling_factor<TokenType>()
        } else {
            if (Token::is_same_token<TokenSwap::LiquidityToken<FLY::FLY, STC::STC>, TokenType>()) {
                valuation<FLY::FLY, STC::STC>(amount)
            } else {
                valuation<FAI::FAI, FLY::FLY>(amount)
            }
        }
    }


    public fun fee_calc(payout: u128, fee: u128): u128 {
        let fee_exp = ExponentialU256::exp_direct(fee);
        let payout_exp = ExponentialU256::exp_direct(payout);
        let fee_amount = ExponentialU256::mul_exp(payout_exp, fee_exp);
        ExponentialU256::mantissa_to_u128(fee_amount)
    }

    public fun profit_calc(value: u128, payout: u128, dao_fee: u128): u128 {
        value - payout - dao_fee
    }

    public fun markdown<Token_x: store+drop+copy, Token_y: store+drop+copy>(): u128 {
        let fly_decimal = Token::scaling_factor<FLY::FLY>();
        let (reserve_x, reserve_y) = TokenSwap::get_reserves<Token_x, Token_y>();
        let total_value = get_total_value<Token_x, Token_y>();

        if (Token::is_same_token<Token_x, FLY::FLY>()) {
            let reserve_y_div_total_value_exp = ExponentialU256::exp(2*reserve_y, total_value);
            let reserve_y_div_total_value_mul_dec_exp =
                ExponentialU256::mul_scalar_exp(reserve_y_div_total_value_exp, fly_decimal);
            ExponentialU256::mantissa_to_u128(reserve_y_div_total_value_mul_dec_exp)
        } else {
            let reserve_x_div_total_value_exp = ExponentialU256::exp(2*reserve_x, total_value);
            let reserve_x_div_total_value_mul_dec_exp =
                ExponentialU256::mul_scalar_exp(reserve_x_div_total_value_exp, fly_decimal);
            ExponentialU256::truncate_to_u128(reserve_x_div_total_value_mul_dec_exp)
        }
    }

    fun get_total_value<Token_x: store+copy+drop, Token_y: store+copy+drop>(): u128 {
        let k_value = get_k_value<Token_x, Token_y>();
        2 * (Math::sqrt(k_value) as u128)
    }

    fun valuation<Token_x: store+drop+copy, Token_y: store+drop+copy>(amount: u128): u128 {
        let total_value = get_total_value<Token_x, Token_y>();
        let total_amount = Token::market_cap<TokenSwap::LiquidityToken<Token_x, Token_y>>();
        let value_exp = ExponentialU256::exp(total_value * amount, total_amount);
        ExponentialU256::truncate_to_u128(value_exp)
    }

    fun get_k_value<Token_x: store+drop+copy, Token_y: store+drop+copy>(): u128{
        let p_decimals = Token::scaling_factor<TokenSwap::LiquidityToken<Token_x, Token_y>>();
        let x_decimals = Token::scaling_factor<Token_x>();
        let y_decimals = Token::scaling_factor<Token_y>();
        let div_decimals = x_decimals * y_decimals / p_decimals;
        let (reserve_x, reserve_y) = TokenSwap::get_reserves<Token_x, Token_y>();
        let reserve_x_exp = ExponentialU256::exp(reserve_x, 1);
        let reserve_y_exp = ExponentialU256::exp(reserve_y, 1);
        let x_mul_y = ExponentialU256::mul_exp(reserve_x_exp, reserve_y_exp);
        let x_mul_y_div_dec = ExponentialU256::div_scalar_exp(x_mul_y, div_decimals);
        ExponentialU256::truncate_to_u128(x_mul_y_div_dec)
    }

    public fun new_index(old_index: u128, amount: u128, stake_amount: u128): u128 {
        let old_index_exp = ExponentialU256::exp_direct(old_index);
        let distribute_ratio = ExponentialU256::exp(amount, stake_amount);
        let distribute_ratio_add_one = ExponentialU256::add_exp(ExponentialU256::exp(1, 1), distribute_ratio);
        let new_index_exp = ExponentialU256::mul_exp(old_index_exp, distribute_ratio_add_one);
        ExponentialU256::mantissa_to_u128(new_index_exp)
    }

    public fun reward(pool_index: u128, user_index: u128, amount: u128): u128 {
        let pool_index_exp = ExponentialU256::exp_direct(pool_index);
        let user_index_exp = ExponentialU256::exp_direct(user_index);
        let amount_exp = ExponentialU256::exp_direct(amount);
        let amount_exp_mul_pool_index_exp = ExponentialU256::mul_exp(amount_exp, pool_index_exp);
        let total_exp = ExponentialU256::div_exp(amount_exp_mul_pool_index_exp, user_index_exp);
        let total = ExponentialU256::mantissa_to_u128(total_exp);
        total - amount
    }

    public fun next_reward_exp(reward_rate: u128): Exp {
        let total_fly = Token::market_cap<FLY::FLY>();
        let reward_rate_exp = ExponentialU256::exp_direct(reward_rate);
        ExponentialU256::mul_exp(ExponentialU256::exp_direct(total_fly), reward_rate_exp)
    }
}
}