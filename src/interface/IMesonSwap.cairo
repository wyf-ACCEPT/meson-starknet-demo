use starknet::{ContractAddress, EthAddress};

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
