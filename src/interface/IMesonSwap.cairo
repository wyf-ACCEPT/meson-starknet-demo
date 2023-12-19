use starknet::{ContractAddress, EthAddress};

#[starknet::interface]
trait MesonSwapTrait<TState> {
    // View functions
    fn getPostedSwap(self: @TState, encodedSwap: u256) -> (u64, EthAddress, ContractAddress);

    // Modifier
    fn verifyEncodedSwap(self: @TState, encodedSwap: u256);     // Need assert inside

    // Write functions
    fn postSwap(ref self: TState, encodedSwap: u256, r: u256, yParityAndS: u256, postingValue: u256);
    fn bondSwap(ref self: TState, encodedSwap: u256, poolIndex: u64);
    fn cancelSwap(ref self: TState, encodedSwap: u256);
    fn executeSwap(ref self: TState, encodedSwap: u256, r: u256, yParityAndS: u256, recipient: u256, depositToPool: bool);
    fn directExecuteSwap(ref self: TState, encodedSwap: u256, r: u256, yParityAndS: u256, initiator: EthAddress, recipient: EthAddress);
}
