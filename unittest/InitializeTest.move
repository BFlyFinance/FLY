address 0xA4c60527238c2893deAF3061B759c11E {
module InitializeTest {
    use 0xA4c60527238c2893deAF3061B759c11E::Initialize;
    use 0xA4c60527238c2893deAF3061B759c11E::TestHelper;

    #[test(sender = @0xA4c60527238c2893deAF3061B759c11E)]
    public fun initialize_treasury_test(sender: signer) {
        TestHelper::before_test();
        Initialize::initialize_bond_stake(&sender);
    }
}
}