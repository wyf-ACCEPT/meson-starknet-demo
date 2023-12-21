use starknet::{ContractAddress, EthAddress};

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
    fn directRelease(ref self: TState, encodedSwap: u256, r: u256, yParityAndS: u256, initiator: EthAddress, recipient: EthAddress);
}

