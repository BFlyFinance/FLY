address FLYAdmin {
#[test_only]
module InitializeTest {
    #[test_only]
    use FLYAdmin::Initialize;
    #[test_only]
    use FLYAdmin::TestHelper;

    #[test_only]
    #[test(sender = @FLYAdmin)]
    public fun initialize_treasury_test(sender: signer) {
        TestHelper::before_test();
        Initialize::initialize_bond_stake(&sender);
    }
}
}