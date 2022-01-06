address 0x7231Eb1A18d8711336B21f6106697253 {
module TestHelper {
    use 0x1::Token;
    use 0x1::Account;
    use 0x1::STC ;
    use 0x1::Timestamp;
    use 0x1::CoreAddresses;
    use 0x1::NFT;
    use 0x1::ChainId;
    use 0x1::Oracle;
    use 0x7231Eb1A18d8711336B21f6106697253::Admin;
    use 0x7231Eb1A18d8711336B21f6106697253::Initialize;

    struct GenesisSignerCapability has key {
        cap: Account::SignerCapability,
    }

    public fun before_test() {
        let stdlib = Account::create_genesis_account(CoreAddresses::GENESIS_ADDRESS());
        //        Debug::print(&Signer::address_of(&stdlib));
        //        Debug::print(&CoreAddresses::GENESIS_ADDRESS());
        Timestamp::initialize(&stdlib, 1631244104193u64);
        Token::register_token<STC::STC>(&stdlib, 9u8);
        ChainId::initialize(&stdlib, 254);

        Oracle::initialize(&stdlib);
        NFT::initialize(&stdlib);

//        let token_address = @0x4fe7BBbFcd97987b966415F01995a229;
//        let token_signer = Account::create_genesis_account(token_address);
//
        let cap = Account::remove_signer_capability( & stdlib);
        let genesis_cap = GenesisSignerCapability { cap:cap };
        move_to( & stdlib, genesis_cap);
        let admin_signer = Account::create_genesis_account(Admin::admin_address());
        Initialize::initialize_treasury(&admin_signer);
    }

}
}