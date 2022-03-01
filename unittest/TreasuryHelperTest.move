address FLYAdmin {
module TreasuryHelperTest {
    use  FLYAdmin::TreasuryHelper;

    #[test]
    public fun reward_test() {
        let reward = TreasuryHelper::reward(2000000000000000000, 1000000000000000000, 1000000000);
        assert!(reward == 1000000000, 1);
    }

    #[test]
    public fun index_test() {
        let index = TreasuryHelper::new_index(1000000000000000000, 1000000000, 1000000000);
        assert!(index == 2000000000000000000, 2);
    }

}
}