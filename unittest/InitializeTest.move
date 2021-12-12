address 0xb987F1aB0D7879b2aB421b98f96eFb44 {
module InitializeTest {
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::Initialize;
    use 0xb987F1aB0D7879b2aB421b98f96eFb44::TestHelper;

    #[test(sender = @0xb987F1aB0D7879b2aB421b98f96eFb44)]
    public fun initialize_treasury_test(sender: signer) {
        TestHelper::before_test();
        Initialize::initialize_bond_stake(&sender);
    }
}
}