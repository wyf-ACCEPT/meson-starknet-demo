use meson_starknet_demo::interface::{
    IMesonManager::MesonManagerTrait,
    IMesonSwap::MesonSwapTrait,
    IMesonPools::MesonPoolsTrait,
};

#[starknet::contract]
mod Meson {
    use meson_starknet_demo::interface::IMesonManager::MesonManagerTrait;
    use meson_starknet_demo::utils::MesonConstants;
    use meson_starknet_demo::utils::MesonHelpers::{
        _outTokenIndexFrom, _inTokenIndexFrom, _tokenType, _inChainFrom,
        _poolTokenIndexFrom, _amountFrom, _expireTsFrom
    };
    use starknet::{
        EthAddress, ContractAddress,
        contract_address::ContractAddressZeroable,
        eth_address::EthAddressZeroable,
        get_caller_address, get_block_timestamp,
    };
    use meson_starknet_demo::utils::MesonStates::MesonStatesComponent;
    
    component!(path: MesonStatesComponent, storage: storage, event: MesonEvent);

    impl MesonInternalImpl = MesonStatesComponent::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        #[nested(v0)]
        #[substorage(v0)]
        storage: MesonStatesComponent::Storage
    }
    
    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        MesonEvent: MesonStatesComponent::Event
    }

    #[abi(embed_v0)]
    impl MesonManager of super::MesonManagerTrait<ContractState> {
        // View functions
        fn getSupportedTokens(self: @ContractState) -> (Array<ContractAddress>, Array<u8>) {
            // TODO: test this function
            let mut tokens: Array<ContractAddress> = array![];
            let mut tokenIndexes: Array<u8> = array![];
            let mut i = 1;
            loop {
                let token = self.storage.tokenForIndex.read(i);
                if token != ContractAddressZeroable::zero() {
                    tokens.append(token);
                    tokenIndexes.append(i);
                }
                if i == 255 {
                    break;
                }
                i += 1;
            };
            (tokens, tokenIndexes)
        }

        // Modifier
        fn onlyOwner(self: @ContractState) {
            assert(
                get_caller_address() == self.storage.owner.read(), 
                'Only owner can call!'
            );
        }

        fn onlyPremiumManager(self: @ContractState) {
            assert(
                get_caller_address() == self.storage.premiumManager.read(), 
                'Only premium manager can call!'
            );
        }

        // Write functions
        fn addSupportToken(ref self: ContractState, token: ContractAddress, index: u8) {
            self.onlyOwner();
            self.storage._addSupportToken(token, index);
        }

        fn removeSupportToken(ref self: ContractState, index: u8) {
            self.onlyOwner();
            self.storage._removeSupportToken(index);
        }

        fn transferOwnership(ref self: ContractState, newOwner: ContractAddress) {
            self.onlyOwner();
            self.storage._transferOwnership(newOwner);
        }
        
        fn transferPremiumManager(ref self: ContractState, newPremiumManager: ContractAddress) {
            self.onlyPremiumManager();
            self.storage._transferPremiumManager(newPremiumManager);
        }

        fn withdrawServiceFee(ref self: ContractState, tokenIndex: u8, amount: u256, toPoolIndex: u64) {
            self.onlyOwner();
            assert(
                self.storage.ownerOfPool.read(toPoolIndex) != ContractAddressZeroable::zero(),
                'Pool index not registered'
            );
            let poolFrom = _poolTokenIndexFrom(tokenIndex, 0);
            let poolTo = _poolTokenIndexFrom(tokenIndex, toPoolIndex);
            self.storage.balanceOfPoolToken.write(
                poolFrom, self.storage.balanceOfPoolToken.read(poolFrom) - amount
            );
            self.storage.balanceOfPoolToken.write(
                poolTo, self.storage.balanceOfPoolToken.read(poolTo) + amount
            );
        }

    }

    #[abi(embed_v0)]
    impl MesonSwap of super::MesonSwapTrait<ContractState> {
        // View functions
        fn getPostedSwap(self: @ContractState, encodedSwap: u256) -> (u64, EthAddress, ContractAddress) {
            self.storage.postedSwaps.read(encodedSwap)
        }

        // Modifier
        fn verifyEncodedSwap(self: @ContractState, encodedSwap: u256) {
            assert(
                _inChainFrom(encodedSwap) == MesonConstants::SHORT_COIN_TYPE, 
                'Swap not for this chain!'
            );
            assert(
                _tokenType(_inTokenIndexFrom(encodedSwap)) == _tokenType(_outTokenIndexFrom(encodedSwap)),
                'In & out token types not match!'
            );

            let (poolIndex, initiator, fromAddress) = self.getPostedSwap(encodedSwap);
            assert(
                poolIndex == 0 && initiator == EthAddressZeroable::zero() && fromAddress == ContractAddressZeroable::zero(), 'Swap already exists'
            );

            assert(
                _amountFrom(encodedSwap) <= MesonConstants::MAX_SWAP_AMOUNT, 
                'Swap amount too large!'
            );

            let delta = _expireTsFrom(encodedSwap) - get_block_timestamp().into();
            assert(delta > MesonConstants::MIN_BOND_TIME_PERIOD, 'Expire ts too early');
            assert(delta < MesonConstants::MAX_BOND_TIME_PERIOD, 'Expire ts too late');
        }

        // Write functions
        fn postSwap(ref self: ContractState, encodedSwap: u256, r: u256, yParityAndS: u256, postingValue: u256) {}

        fn bondSwap(ref self: ContractState, encodedSwap: u256, poolIndex: u64) {}

        fn cancelSwap(ref self: ContractState, encodedSwap: u256) {}

        fn executeSwap(ref self: ContractState, encodedSwap: u256, r: u256, yParityAndS: u256, recipient: u256, depositToPool: bool) {}

        fn directExecuteSwap(ref self: ContractState, encodedSwap: u256, r: u256, yParityAndS: u256, initiator: EthAddress, recipient: EthAddress) {}
        
    }

}
