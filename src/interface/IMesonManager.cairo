use starknet::ContractAddress;

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
