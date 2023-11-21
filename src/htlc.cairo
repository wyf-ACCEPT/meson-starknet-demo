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
    ) -> (u256, u64, ContractAddress);

    fn view_left_time(
        self: @TContractState,
        hashlock: u256
    ) -> (bool, u64);
}

#[starknet::contract]
mod HashTimeLock {
    use super::{ContractAddress, HashTimeLockTrait};
    use starknet::{
        get_caller_address, get_contract_address, 
        get_block_timestamp, contract_address::ContractAddressZeroable
    };
    use openzeppelin::token::erc20::interface::{
        IERC20Dispatcher, IERC20DispatcherTrait,
    };
    use alexandria_bytes::{
        Bytes, BytesTrait
    };

    #[storage]
    struct Storage {
        token: ContractAddress,
        locked_assets: LegacyMap<u256, (u256, u64, ContractAddress)>,
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
            let (_, possible_expire_time, _) = self.locked_assets.read(hashlock);
            assert(possible_expire_time == 0, 'Already locked with this hash!');

            let expire_time = get_block_timestamp() + timelimit;
            self.locked_assets.write(hashlock, (amount, expire_time, receiver));
            IERC20Dispatcher { contract_address: self.token.read() }.transfer_from(
                get_caller_address(), get_contract_address(), amount
            );
        }

        fn claim_asset(
            ref self: ContractState, 
            secret: u256
        ) {
            // Calculate the hash of the secret
            let mut bytes: Bytes = BytesTrait::new(0, array![]);
            bytes.append_u256(secret);
            let hashlock = bytes.keccak();

            // Read from states and check
            let (amount, expire_time, receiver) = self.locked_assets.read(hashlock);
            assert(amount != 0, 'No asset locked with this hash!');
            assert(expire_time > get_block_timestamp(), 'Asset expired!');
            assert(get_caller_address() == receiver, 'Not the assigned receiver!');

            // Rewrite the states
            self.locked_assets.write(hashlock, (0, 0, ContractAddressZeroable::zero()));

            // Transfer the asset to the caller
            IERC20Dispatcher { contract_address: self.token.read() }.transfer(
                receiver, amount
            );
        }

        fn view_current_locked_assets(
            self: @ContractState,
            hashlock: u256
        ) -> (u256, u64, ContractAddress) {
            self.locked_assets.read(hashlock)
        }

        fn view_left_time(
            self: @ContractState,
            hashlock: u256
        ) -> (bool, u64) {
            let (_, expire_time, _) = self.locked_assets.read(hashlock);
            let is_expire = expire_time < get_block_timestamp();
            let left_time = {
                if is_expire {
                    get_block_timestamp() - expire_time
                } else {
                    expire_time - get_block_timestamp()
                }
            };
            (is_expire, left_time)
        }
    }
}