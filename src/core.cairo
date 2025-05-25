#[starknet::contract]
mod Meson {
    use core::num::traits::Zero;
    use starknet::{
        EthAddress, ContractAddress, ClassHash,
        // contract_address::ContractAddressZeroable,
        // eth_address::EthAddressZeroable,
        get_caller_address, get_block_timestamp, get_contract_address,
        storage::{
            StoragePointerWriteAccess, StoragePointerReadAccess,
            StorageMapReadAccess, StorageMapWriteAccess,
        },
    };
    use openzeppelin::upgrades::{interface::IUpgradeable, UpgradeableComponent};
    use meson_starknet::interface::{
        MesonViewStorageTrait, MesonManagerTrait, MesonSwapTrait, MesonPoolsTrait
    };
    use meson_starknet::utils::{
        MesonConstants,
        MesonStates::MesonStatesComponent,
    };
    use meson_starknet::utils::MesonHelpers::{
        _outTokenIndexFrom, _inTokenIndexFrom, _tokenType, _inChainFrom, _outChainFrom,
        _poolTokenIndexFrom, _poolIndexFrom, _tokenIndexFrom, _poolTokenIndexForOutToken,
        _amountFrom, _expireTsFrom, _getSwapId, _coreTokenAmount, _amountToLock,
        _checkReleaseSignature, _feeWaived, _ethAddressFromStarknet, _serviceFee,
    };
    
    component!(path: MesonStatesComponent, storage: storage, event: MesonEvent);
    component!(path: UpgradeableComponent, storage: upgradeable, event: UpgradeableEvent);

    impl MesonInternalImpl = MesonStatesComponent::InternalImpl<ContractState>;
    impl UpgradeableInternalImpl = UpgradeableComponent::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        #[nested(v0)]
        #[substorage(v0)]
        storage: MesonStatesComponent::Storage,
        #[substorage(v0)]
        upgradeable: UpgradeableComponent::Storage,
    }
    
    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        MesonEvent: MesonStatesComponent::Event,
        #[flat]
        UpgradeableEvent: UpgradeableComponent::Event,
    }

    #[constructor]
    fn constructor(ref self: ContractState, owner: ContractAddress) {
        self.storage.owner.write(owner);
        self.storage.premiumManager.write(owner);
    }

    #[abi(embed_v0)]
    impl MesonViewStorage of MesonViewStorageTrait<ContractState> {
        
        // View functions
        fn getOwner(self: @ContractState) -> ContractAddress {
            self.storage.owner.read()
        }

        fn getPremiumManager(self: @ContractState) -> ContractAddress {
            self.storage.premiumManager.read()
        }

        fn balanceOfPoolToken(self: @ContractState, poolTokenIndex: u64) -> u256 {
            self.storage.balanceOfPoolToken.read(poolTokenIndex)
        }

        fn ownerOfPool(self: @ContractState, poolIndex: u64) -> ContractAddress {
            self.storage.ownerOfPool.read(poolIndex)
        }

        fn poolOfAuthorizedAddr(self: @ContractState, addr: ContractAddress) -> u64 {
            self.storage.poolOfAuthorizedAddr.read(addr)
        }

        fn getIndexOfToken(self: @ContractState, token: ContractAddress) -> u8 {
            self.storage.indexOfToken.read(token)
        }

        fn getTokenForIndex(self: @ContractState, index: u8) -> ContractAddress {
            self.storage.tokenForIndex.read(index)
        }

        fn getPostedSwap(self: @ContractState, encodedSwap: u256) 
            -> (u64, EthAddress, ContractAddress) {
            self.storage.postedSwaps.read(encodedSwap)
        }

        fn getLockedSwap(self: @ContractState, swapId: u256) 
            -> (u64, u64, ContractAddress) {
            self.storage.lockedSwaps.read(swapId)
        }

        fn getShortCoinType(self: @ContractState) -> u16 {
            MesonConstants::SHORT_COIN_TYPE
        }

        fn poolTokenBalance(
            self: @ContractState, 
            token: ContractAddress,
            addr: ContractAddress
        ) -> u256 {
            let tokenIndex: u8 = self.storage.indexOfToken.read(token);
            let poolIndex: u64 = self.storage.poolOfAuthorizedAddr.read(addr);
            if poolIndex == 0 || tokenIndex == 0 {
                0
            } else {
                let poolTokenIndex: u64 = _poolTokenIndexFrom(tokenIndex, poolIndex);
                self.storage.balanceOfPoolToken.read(poolTokenIndex)
            }
        }

        fn serviceFeeCollected(
            self: @ContractState, 
            tokenIndex: u8
        ) -> u256 {
            let poolTokenIndex: u64 = _poolTokenIndexFrom(tokenIndex, 0);
            self.storage.balanceOfPoolToken.read(poolTokenIndex)
        }
        
    }

    #[abi(embed_v0)]
    impl MesonManager of MesonManagerTrait<ContractState> {

        // View functions
        fn getSupportedTokens(self: @ContractState) -> (Array<ContractAddress>, Array<u8>) {
            // TODO: test this function
            let mut tokens: Array<ContractAddress> = array![];
            let mut tokenIndexes: Array<u8> = array![];
            let mut i = 1;
            loop {
                let token = self.storage.tokenForIndex.read(i);
                if token.is_non_zero() {
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

        fn withdrawServiceFee(
            ref self: ContractState, tokenIndex: u8, amount: u256, toPoolIndex: u64
        ) {
            self.onlyOwner();
            assert(
                self.storage.ownerOfPool.read(toPoolIndex).is_non_zero(),
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
    impl MesonSwap of MesonSwapTrait<ContractState> {

        // Modifier
        fn verifyEncodedSwap(self: @ContractState, encodedSwap: u256) {
            assert(
                _inChainFrom(encodedSwap) == MesonConstants::SHORT_COIN_TYPE, 
                'Swap not for this chain!'
            );
            assert(
                _tokenType(_inTokenIndexFrom(encodedSwap)) == 
                _tokenType(_outTokenIndexFrom(encodedSwap)),
                'In & out token types not match!'
            );

            let (poolIndex, initiator, fromAddress) = self.getPostedSwap(encodedSwap);
            assert(
                poolIndex == 0 && initiator.is_zero() &&  fromAddress.is_zero(), 
                'Swap already exists'
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
        fn postSwap(
            ref self: ContractState, 
            encodedSwap: u256, 
            initiator: EthAddress, 
            poolIndex: u64
        ) {
            // TODO: This functions is only for user?
            self.verifyEncodedSwap(encodedSwap);

            let tokenIndex = _inTokenIndexFrom(encodedSwap);
            let fromAddress = get_caller_address();
            
            // TODO: Don't need to check request signature?
            // _checkRequestSignature(encodedSwap, r, yParityAndS, initiator);

            self.storage.postedSwaps.write(
                encodedSwap, (poolIndex, initiator, fromAddress)
            );
            self.storage._depositToken(tokenIndex, fromAddress, _amountFrom(encodedSwap));
        }

        fn bondSwap(ref self: ContractState, encodedSwap: u256, poolIndex: u64) {
            let (oldPoolIndex, initiator, fromAddress) = self.getPostedSwap(encodedSwap);
            let poolOwner = get_caller_address();

            assert(fromAddress.is_non_zero(), 'Swap not exists!');
            assert(oldPoolIndex == 0, 'Swap bonded to others!');
            assert(
                self.storage.poolOfAuthorizedAddr.read(poolOwner) == poolIndex,
                'Not authorized address!'
            );

            self.storage.postedSwaps.write(
                encodedSwap, (poolIndex, initiator, fromAddress)
            );
        }

        fn cancelSwap(ref self: ContractState, encodedSwap: u256) {
            let (_oldPoolIndex, _initiator, fromAddress) = self.getPostedSwap(encodedSwap);
            let tokenIndex = _inTokenIndexFrom(encodedSwap);
            
            assert(fromAddress.is_non_zero(), 'Swap not exists!');
            assert(
                _expireTsFrom(encodedSwap) < get_block_timestamp().into(), 
                'Swap is still locked!'
            );

            self.storage.postedSwaps.write(
                encodedSwap, (0, 0.try_into().unwrap(), 0_felt252.try_into().unwrap())
            );
            self.storage._safeTransfer(tokenIndex, fromAddress, _amountFrom(encodedSwap));
        }

        fn executeSwap(
            ref self: ContractState, 
            encodedSwap: u256, 
            r: u256, 
            yParityAndS: u256, 
            recipient: EthAddress, 
            depositToPool: bool
        ) {
            let (poolIndex, initiator, _fromAddress) = self.getPostedSwap(encodedSwap);
            let amount = _amountFrom(encodedSwap);
            let tokenIndex = _inTokenIndexFrom(encodedSwap);
            let poolTokenIndex = _poolTokenIndexFrom(tokenIndex, poolIndex);

            assert(poolIndex != 0, 'Pool index cannot be 0!');

            _checkReleaseSignature(encodedSwap, recipient, r, yParityAndS, initiator);

            self.storage.postedSwaps.write(
                encodedSwap, (0, 0.try_into().unwrap(), 0_felt252.try_into().unwrap())
            );
            if depositToPool {
                self.storage.balanceOfPoolToken.write(
                    poolTokenIndex, 
                    self.storage.balanceOfPoolToken.read(poolTokenIndex) + amount
                );
            } else {
                let poolOwner = self.storage.ownerOfPool.read(poolIndex);
                self.storage._safeTransfer(tokenIndex, poolOwner, amount);
            }
        }

    }

    #[abi(embed_v0)]
    impl MesonPools of MesonPoolsTrait<ContractState> {

        // Modifier
        fn forTargetChain(self: @ContractState, encodedSwap: u256) {
            assert(
                _outChainFrom(encodedSwap) == MesonConstants::SHORT_COIN_TYPE,
                'Swap not for this chain!'
            );
        }

        // Write functions (LPs)
        fn depositAndRegister(ref self: ContractState, amount: u256, poolTokenIndex: u64) {
            let poolOwner = get_caller_address();
            let poolIndex = _poolIndexFrom(poolTokenIndex);
            let tokenIndex = _tokenIndexFrom(poolTokenIndex);

            assert(amount > 0, 'Amount must be positive!');
            assert(poolIndex != 0, 'Cannot use 0 as pool index!');
            assert(
                self.storage.ownerOfPool.read(poolIndex).is_zero(),
                'Pool index already registered!'
            );
            assert(
                self.storage.poolOfAuthorizedAddr.read(poolOwner) == 0,
                'Signer already registered!'
            );

            self.storage.ownerOfPool.write(poolIndex, poolOwner);
            self.storage.poolOfAuthorizedAddr.write(poolOwner, poolIndex);

            self.storage._depositToken(tokenIndex, poolOwner, amount);
            self.storage.balanceOfPoolToken.write(
                poolTokenIndex, 
                self.storage.balanceOfPoolToken.read(poolTokenIndex) + amount
            );
        }

        fn deposit(ref self: ContractState, amount: u256, poolTokenIndex: u64) {
            let authrizedAddress = get_caller_address();
            let poolIndex = _poolIndexFrom(poolTokenIndex);
            let tokenIndex = _tokenIndexFrom(poolTokenIndex);

            assert(amount > 0, 'Amount must be positive!');
            assert(poolIndex != 0, 'Cannot use 0 as pool index!');
            assert(
                self.storage.poolOfAuthorizedAddr.read(authrizedAddress) == poolIndex,
                'Need an authorized address!'
            );

            self.storage._depositToken(tokenIndex, authrizedAddress, amount);
            self.storage.balanceOfPoolToken.write(
                poolTokenIndex, 
                self.storage.balanceOfPoolToken.read(poolTokenIndex) + amount
            );
        }

        fn withdraw(ref self: ContractState, amount: u256, poolTokenIndex: u64) {
            let poolOwner = get_caller_address();
            let poolIndex = _poolIndexFrom(poolTokenIndex);
            let tokenIndex = _tokenIndexFrom(poolTokenIndex);

            assert(amount > 0, 'Amount must be positive!');
            assert(poolIndex != 0, 'Cannot use 0 as pool index!');
            assert(
                self.storage.ownerOfPool.read(poolIndex) == poolOwner,
                'Need the pool owner!'
            );

            self.storage.balanceOfPoolToken.write(
                poolTokenIndex, 
                self.storage.balanceOfPoolToken.read(poolTokenIndex) - amount
            );
            self.storage._safeTransfer(tokenIndex, poolOwner, amount);
        }

        fn addAuthorizedAddr(ref self: ContractState, addr: ContractAddress) {
            let poolOwner = get_caller_address();
            let poolIndex = self.storage.poolOfAuthorizedAddr.read(poolOwner);

            assert(
                self.storage.poolOfAuthorizedAddr.read(addr) == 0,
                'Authorized for another pool!'
            );
            assert(poolIndex != 0, 'Signer have not registered!');
            assert(
                poolOwner == self.storage.ownerOfPool.read(poolIndex),
                'Signer should be pool owner!'
            );

            self.storage.poolOfAuthorizedAddr.write(addr, poolIndex);
        }

        fn removeAuthorizedAddr(ref self: ContractState, addr: ContractAddress) {
            let poolOwner = get_caller_address();
            let poolIndex = self.storage.poolOfAuthorizedAddr.read(poolOwner);

            assert(
                self.storage.poolOfAuthorizedAddr.read(addr) == poolIndex,
                'Not an authorized address!'
            );
            assert(poolIndex != 0, 'Signer have not registered!');
            assert(
                poolOwner == self.storage.ownerOfPool.read(poolIndex),
                'Signer should be pool owner!'
            );

            self.storage.poolOfAuthorizedAddr.write(addr, 0);
        }

        fn transferPoolOwner(ref self: ContractState, addr: ContractAddress) {
            let poolOwner = get_caller_address();
            let poolIndex = self.storage.poolOfAuthorizedAddr.read(poolOwner);

            assert(
                self.storage.poolOfAuthorizedAddr.read(addr) == poolIndex,
                'Not an authorized address!'
            );
            assert(poolIndex != 0, 'Signer have not registered!');
            assert(
                poolOwner == self.storage.ownerOfPool.read(poolIndex),
                'Signer should be pool owner!'
            );

            self.storage.ownerOfPool.write(poolIndex, addr);
        }

        // Write functions (users)
        fn lockSwap(
            ref self: ContractState, 
            encodedSwap: u256, 
            initiator: EthAddress, 
            recipient: ContractAddress
        ) {
            self.forTargetChain(encodedSwap);

            let swapId = _getSwapId(encodedSwap, initiator);
            let (existPoolIndex, _, _) = self.getLockedSwap(swapId);
            let poolIndex = self.storage.poolOfAuthorizedAddr.read(get_caller_address());
            let poolTokenIndex = _poolTokenIndexForOutToken(encodedSwap, poolIndex);
            let until = get_block_timestamp().into() + MesonConstants::LOCK_TIME_PERIOD;
            let coreAmount = _coreTokenAmount(encodedSwap);

            assert(existPoolIndex == 0, 'Swap already exists');
            assert(poolIndex != 0, 'Caller not registered!');
            assert(
                until < _expireTsFrom(encodedSwap) - 5 * 60,    // 5 minutes left
                'Expire time is soon!'
            );

            if coreAmount > 0 {
                // TODO: add core token's case
            }
            self.storage.balanceOfPoolToken.write(
                poolTokenIndex, 
                self.storage.balanceOfPoolToken.read(poolTokenIndex) - _amountToLock(encodedSwap)
            );
            self.storage.lockedSwaps.write(
                swapId, (poolIndex, until.try_into().unwrap(), recipient)
            );

        }

        fn unlock(ref self: ContractState, encodedSwap: u256, initiator: EthAddress) {
            let swapId = _getSwapId(encodedSwap, initiator);
            let (poolIndex, until, _recipient) = self.getLockedSwap(swapId);
            let poolTokenIndex = _poolTokenIndexForOutToken(encodedSwap, poolIndex);
            let coreAmount = _coreTokenAmount(encodedSwap);

            assert(poolIndex != 0, 'Swap does not exist!');
            assert(until < get_block_timestamp().into(), 'Swap still in lock!');

            if coreAmount > 0 {
                // TODO
            }
            self.storage.balanceOfPoolToken.write(
                poolTokenIndex, 
                self.storage.balanceOfPoolToken.read(poolTokenIndex) + _amountToLock(encodedSwap)
            );
            self.storage.lockedSwaps.write(
                swapId, (0, 0, 0_felt252.try_into().unwrap())
            );
        }

        fn release(
            ref self: ContractState, 
            encodedSwap: u256, 
            r: u256, 
            yParityAndS: u256, 
            initiator: EthAddress
        ) {
            let feeWaived = _feeWaived(encodedSwap);
            let swapId = _getSwapId(encodedSwap, initiator);
            let (poolIndex, _until, recipient) = self.getLockedSwap(swapId);
            let coreAmount = _coreTokenAmount(encodedSwap);
            let recipientAsEth = _ethAddressFromStarknet(recipient);
            let serviceFeePoolTokenIndex = _poolTokenIndexForOutToken(encodedSwap, 0);
            let mut releaseAmount = _amountToLock(encodedSwap);

            _checkReleaseSignature(encodedSwap, recipientAsEth, r, yParityAndS, initiator);
            assert(poolIndex != 0, 'Swap does not exist!');
            assert(
                _expireTsFrom(encodedSwap) > get_block_timestamp().into(), 
                'Cannot release. Expired!'
            );
            assert(recipient.is_non_zero(), 'Recipient cannot be zero!');

            if feeWaived { 
                self.onlyPremiumManager();
            } else {
                let serviceFee = _serviceFee(encodedSwap);
                releaseAmount -= serviceFee;
                self.storage.balanceOfPoolToken.write(
                    serviceFeePoolTokenIndex,
                    self.storage.balanceOfPoolToken.read(serviceFeePoolTokenIndex) + serviceFee
                );
            }
            if coreAmount > 0 {
                // TODO
            }
            self.storage._safeTransfer(
                _outTokenIndexFrom(encodedSwap), recipient, releaseAmount
            );
            self.storage.lockedSwaps.write(
                swapId, (0, 0, get_contract_address())      
            );      // It correspond to `_lockedSwaps[swapId] = 1` in solidity.
        }

        fn directRelease(
            ref self: ContractState, 
            encodedSwap: u256, 
            r: u256, 
            yParityAndS: u256, 
            initiator: EthAddress, 
            recipient: ContractAddress
        ) {
            let feeWaived = _feeWaived(encodedSwap);
            let swapId = _getSwapId(encodedSwap, initiator);
            // let (poolIndex, until, recipient) = self.getLockedSwap(swapId);
            let poolIndex = self.storage.poolOfAuthorizedAddr.read(get_caller_address());
            let (existPoolIndex, _, _) = self.getLockedSwap(swapId);
            // let tokenIndex = _outTokenIndexFrom(encodedSwap);
            let coreAmount = _coreTokenAmount(encodedSwap);
            let recipientAsEth = _ethAddressFromStarknet(recipient);
            let serviceFeePoolTokenIndex = _poolTokenIndexForOutToken(encodedSwap, 0);
            let mut releaseAmount = _amountToLock(encodedSwap);

            self.forTargetChain(encodedSwap);
            _checkReleaseSignature(encodedSwap, recipientAsEth, r, yParityAndS, initiator);
            assert(poolIndex != 0, 'Swap does not exist!');
            assert(existPoolIndex == 0, 'Swap already exists');
            assert(poolIndex != 0, 'Caller not registered!');
            assert(
                _expireTsFrom(encodedSwap) > get_block_timestamp().into(), 
                'Cannot release. Expired!'
            );
            assert(recipient.is_non_zero(), 'Recipient cannot be zero!');

            if feeWaived { 
                self.onlyPremiumManager();
            } else {
                let serviceFee = _serviceFee(encodedSwap);
                releaseAmount -= serviceFee;
                self.storage.balanceOfPoolToken.write(
                    serviceFeePoolTokenIndex,
                    self.storage.balanceOfPoolToken.read(serviceFeePoolTokenIndex) + serviceFee
                );
            }
            if coreAmount > 0 {
                // TODO
            }
            self.storage._safeTransfer(
                _outTokenIndexFrom(encodedSwap), recipient, releaseAmount
            );
            self.storage.lockedSwaps.write(
                swapId, (0, 0, get_contract_address())      
            );      // It correspond to `_lockedSwaps[swapId] = 1` in solidity.
        }
    }

    #[abi(embed_v0)]
    impl UpgradeableImpl of IUpgradeable<ContractState> {
        fn upgrade(ref self: ContractState, new_class_hash: ClassHash) {
            self.onlyOwner();
            self.upgradeable.upgrade(new_class_hash);
        }
    }

}
