address 0x164FbB953f822FBBA95d582B1794687C {
module InitializeTest {
    use 0x164FbB953f822FBBA95d582B1794687C::Initialize;
    use 0x164FbB953f822FBBA95d582B1794687C::TestHelper;

    #[test(sender = @0x164FbB953f822FBBA95d582B1794687C)]
    public fun initialize_treasury_test(sender: signer) {
        TestHelper::before_test();
        Initialize::initialize_bond_stake(&sender);
    }
}
}