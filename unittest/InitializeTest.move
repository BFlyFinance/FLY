address 0x7231Eb1A18d8711336B21f6106697253 {
module InitializeTest {
    use 0x7231Eb1A18d8711336B21f6106697253::Initialize;
    use 0x7231Eb1A18d8711336B21f6106697253::TestHelper;

    #[test(sender = @0x7231Eb1A18d8711336B21f6106697253)]
    public fun initialize_treasury_test(sender: signer) {
        TestHelper::before_test();
        Initialize::initialize_bond_stake(&sender);
    }
}
}