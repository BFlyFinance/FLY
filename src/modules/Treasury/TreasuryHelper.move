address 0xb987F1aB0D7879b2aB421b98f96eFb44 {
module TreasuryHelper{

    use 0x1::Math;
    use 0x1::Token;
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::FLY;
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::Admin;
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::ExponentialU256;
    use 0x3db7a2da7444995338a2413b151ee437::TokenSwap::{Self, LiquidityToken};

    public fun value_of<TokenType> (amount: u128): u128 {
        if (Admin::is_reserve<TokenType>()) {
            amount * Token::scaling_factor<FLY>() / Token::scaling_factor<TokenType>()
        } else {
            valuation<TokenType>(amount)
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

    public fun markdown<Token_x, Token_y>(): u128 {
        // TODO: calc
        let fly_decimal = Token::scaling_factor<FLY::FLY>();
        let (reserve_x, reserve_y) = TokenSwap::get_reserves<Token_x, Token_y>();
        if (Token::is_same_token<Token_x, FLY::FLY>()) {
            reserve_y * 2 * fly_decimal / get_total_value<Token_x, Token_y>()
        } else {
            reserve_x * 2 * fly_decimal / get_total_value<Token_x, Token_y>()
        }
    }

    fun get_total_value<Token_x, Token_y>(): u128 {
        let k_value = get_k_value<TokenSwap::LiquidityToken<Token_x, Token_y>>();
        2 * (Math::sqrt(k_value) as u128)
    }

    fun valuation<Token_x, Token_y>(amount: u128): u128 {
        let total_value = get_total_value<TokenSwap::LiquidityToken<Token_x, Token_y>>();
        let total_amount = Token::market_cap<TokenSwap::LiquidityToken<Token_x, Token_y>>();
        total_value * (amount / total_ammount)
    }

    fun get_k_value<Token_x, Token_y>(): u128{
        let x_decimals = Token::scaling_factor<Token_x>();
        let y_decimals = Token::scaling_factor<Token_y>();
        let p_decimals = Token::scaling_factor<TokenSwap::LiquidityToken<Token_x, Token_y>>();
        let (reserve_x, reserve_y) = TokenSwap::get_reserves<Token_x, Token_y>();
        let decimals = x_decimals * y_decimals / p_decimals;
        reserve_x * reserve_y / p_decimals
    }

    public fun new_index(old_index: u128, amount: u128, stake_amount: u128): u128 {
        let old_index_exp = ExponentialU256::exp_direct(old_index);
        let distribute_ratio = ExponentialU256::exp(amount, stake_amount);
        let distribute_ratio_add_one = ExponentialU256::add_exp(ExponentialU256::exp(1, 1), distribute_ratio);
        let new_index_exp = ExponentialU256::mul_exp(old_index_exp, distribute_ratio_add_one);
        Exponential::mantissa_to_u128(new_index_exp)
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
}
}