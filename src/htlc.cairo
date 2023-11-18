use starknet::ContractAddress;
// use starknet::eth_address::EthAddress;

#[starknet::interface]
trait HashTimeLockTrait<TContractState> {
    fn lock_asset(
        ref self: TContractState, 
        hashlock: u256, 
        timelimit: u64, 
        amount: u256, 
        receiver: ContractAddress
    );

    fn claim_asset(
        ref self: TContractState, 
        secret: u256
    );

    fn view_current_locked_assets(
        self: @TContractState,
        hashlock: u256
    ) -> (u256, u64);
}

#[starknet::contract]
mod HashTimeLock {
    use super::{ContractAddress, HashTimeLockTrait};
    use starknet::{get_caller_address, get_contract_address, get_block_timestamp};
    use openzeppelin::token::erc20::interface::{
        IERC20Dispatcher, IERC20DispatcherTrait,
    };

    #[storage]
    struct Storage {
        token: ContractAddress,
        locked_assets: LegacyMap<u256, (u256, u64)>,
    }

    #[constructor]
    fn constructor(ref self: ContractState, token: ContractAddress) {
        self.token.write(token);
    }

    #[external(v0)]
    impl HashTimeLockImpl of HashTimeLockTrait<ContractState>{
        fn lock_asset(
            ref self: ContractState, 
            hashlock: u256, 
            timelimit: u64, 
            amount: u256, 
            receiver: ContractAddress
        ) {
            // IERC20Dispatcher { contract_address: self.token.read() }.transfer_from(
            //     get_caller_address(), get_contract_address(), amount
            // );
            let expire_time = get_block_timestamp() + timelimit;
            self.locked_assets.write(hashlock, (amount, expire_time));
        }

        fn claim_asset(
            ref self: ContractState, 
            secret: u256
        ) {
        }

        fn view_current_locked_assets(
            self: @ContractState,
            hashlock: u256
        ) -> (u256, u64) {
            self.locked_assets.read(hashlock)
        }
    }
}
