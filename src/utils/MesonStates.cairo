#[starknet::component]
mod MesonStatesComponent {
    use starknet::ContractAddress;
    use meson_starknet_demo::utils::MesonHelpers::{
        PostedSwap, LockedSwap,
        _poolTokenIndexFrom, _isCoreToken
    };

    #[storage]
    struct Storage {
        owner: ContractAddress,
        premiumManager: ContractAddress,
        balanceOfPoolToken: LegacyMap<u64, u256>,
        ownerOfPool: LegacyMap<u64, ContractAddress>,
        poolOfAuthorizedAddr: LegacyMap<ContractAddress, u64>,
        indexOfToken: LegacyMap<ContractAddress, u8>,
        tokenForIndex: LegacyMap<u8, ContractAddress>,
        postedSwaps: LegacyMap<u256, PostedSwap>,
        lockedSwaps: LegacyMap<u256, LockedSwap>,
    }

    mod Errors {
        const AMOUNT_NOT_ZERO: felt252 = 'Amount must > 0';
    }

    #[generate_trait]       // Internal functions that can be used in son contracts
    impl MesonStatesInternal<
        TContractState, +HasComponent<TContractState>
    > of InternalTrait<TContractState> {
        
        fn poolTokenBalance(
            self: @ComponentState<TContractState>, 
            token: ContractAddress,
            addr: ContractAddress
        ) -> u256 {
            let tokenIndex: u8 = self.indexOfToken.read(token);
            let poolIndex: u64 = self.poolOfAuthorizedAddr.read(addr);
            if poolIndex == 0 || tokenIndex == 0 {
                0
            } else {
                let poolTokenIndex: u64 = _poolTokenIndexFrom(tokenIndex, poolIndex);
                self.balanceOfPoolToken.read(poolTokenIndex)
            }
        }

        fn serviceFeeCollected(
            self: @ComponentState<TContractState>, 
            tokenIndex: u8
        ) -> u256 {
            let poolTokenIndex: u64 = _poolTokenIndexFrom(tokenIndex, 0);
            self.balanceOfPoolToken.read(poolTokenIndex)
        }

    //     if (_isCoreToken(tokenIndex)) {
    //     // Core tokens (e.g. ETH or BNB)
    //     require(amount * 1e12 == msg.value, "msg.value does not match the amount");
    //     } else {
    //     // Stablecoins
    //     address token = tokenForIndex[tokenIndex];

    //     require(token != address(0), "Token not supported");
    //     require(Address.isContract(token), "The given token address is not a contract");

    //     if (_needAdjustAmount(tokenIndex)) {
    //         amount *= 1e12;
    //     }
    //     (bool success, bytes memory data) = token.call(abi.encodeWithSelector(
    //         ERC20_TRANSFER_FROM_SELECTOR,
    //         sender,
    //         address(this),
    //         amount
    //     ));
    //     require(success && (data.length == 0 || abi.decode(data, (bool))), "transferFrom failed");

        fn _unsafeDepositToken(
            ref self: ComponentState<TContractState>,
            tokenIndex: u8,
            sender: ContractAddress,
            amount: u256
        ) {
            assert(amount > 0, Errors::AMOUNT_NOT_ZERO);
            if _isCoreToken(tokenIndex) {
                // Core tokens (e.g. ETH or BNB)
                // assert(amount * 1e12 == msg.value, "msg.value does not match the amount");
            } else {
                // // Stablecoins
                // let token: ContractAddress = self.tokenForIndex.read(tokenIndex);
                // assert(token != 0, "Token not supported");
                // assert(Address::is_contract(token), "The given token address is not a contract");
                // if _needAdjustAmount(tokenIndex) {
                //     amount *= 1e12;
                // }
                // let (success, data) = token.call(abi.encodeWithSelector(
                //     ERC20_TRANSFER_FROM_SELECTOR,
                //     sender,
                //     address(this),
                //     amount
                // ));
                // assert(success && (data.length == 0 || abi.decode(data, (bool))), "transferFrom failed");
            }
        }

    }



}