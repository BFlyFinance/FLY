address 0xC137657E5aeD5099592BA07c8ab44CC5 {
module InitializeTest {
    use 0xC137657E5aeD5099592BA07c8ab44CC5::Initialize;
    use 0xC137657E5aeD5099592BA07c8ab44CC5::TestHelper;

    #[test(sender = @0xC137657E5aeD5099592BA07c8ab44CC5)]
    public fun initialize_treasury_test(sender: signer) {
        TestHelper::before_test();
        Initialize::initialize_bond_stake(&sender);
    }
}
}