address FLYAdmin {
module InitializeTest {
    use FLYAdmin::Initialize;
    use FLYAdmin::TestHelper;

    #[test(sender = @FLYAdmin)]
    public fun initialize_treasury_test(sender: signer) {
        TestHelper::before_test();
        Initialize::initialize_bond_stake(&sender);
    }
}
}