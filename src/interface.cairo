use starknet::{ContractAddress, EthAddress};

#[starknet::interface]
trait MesonManagerTrait<TState> {
    // View functions
    fn getSupportedTokens(self: @TState) -> (Array<ContractAddress>, Array<u8>);

    // Modifier
    fn onlyOwner(self: @TState);
    fn onlyPremiumManager(self: @TState);

    // Write functions
    fn addSupportToken(ref self: TState, token: ContractAddress, index: u8);
    fn removeSupportToken(ref self: TState, index: u8);
    fn transferOwnership(ref self: TState, newOwner: ContractAddress);
    fn transferPremiumManager(ref self: TState, newPremiumManager: ContractAddress);
    fn withdrawServiceFee(ref self: TState, tokenIndex: u8, amount: u256, toPoolIndex: u64);
}

#[starknet::interface]
trait MesonSwapTrait<TState> {
    // View functions
    fn getPostedSwap(self: @TState, encodedSwap: u256) -> (u64, EthAddress, ContractAddress);

    // Modifier
    fn verifyEncodedSwap(self: @TState, encodedSwap: u256);     // Need assert inside

    // Write functions
    fn postSwap(ref self: TState, encodedSwap: u256, initiator: EthAddress, fromAddress: ContractAddress, poolIndex: u64);
    fn bondSwap(ref self: TState, encodedSwap: u256, poolIndex: u64);
    fn cancelSwap(ref self: TState, encodedSwap: u256);
    fn executeSwap(ref self: TState, encodedSwap: u256, r: u256, yParityAndS: u256, recipient: EthAddress, depositToPool: bool);
}

#[starknet::interface]
trait MesonPoolsTrait<TState> {
    // View functions
    fn getLockedSwap(self: @TState, swapId: u256) -> (u64, u64, ContractAddress);

    // Modifier
    fn forTargetChain(self: @TState, encodedSwap: u256);     // Need assert inside

    // Write functions (LPs)
    fn depositAndRegister(ref self: TState, amount: u256, poolTokenIndex: u64);
    fn deposit(ref self: TState, amount: u256, poolTokenIndex: u64);
    fn withdraw(ref self: TState, amount: u256, poolTokenIndex: u64);
    fn addAuthorizedAddr(ref self: TState, addr: ContractAddress);
    fn removeAuthorizedAddr(ref self: TState, addr: ContractAddress);
    fn transferPoolOwner(ref self: TState, addr: ContractAddress);

    // Write functions (users)
    fn lockSwap(ref self: TState, encodedSwap: u256, initiator: EthAddress, recipient: ContractAddress);
    fn unlock(ref self: TState, encodedSwap: u256, initiator: EthAddress);
    fn release(ref self: TState, encodedSwap: u256, r: u256, yParityAndS: u256, initiator: EthAddress);
    fn directRelease(ref self: TState, encodedSwap: u256, r: u256, yParityAndS: u256, initiator: EthAddress, recipient: ContractAddress);
}
