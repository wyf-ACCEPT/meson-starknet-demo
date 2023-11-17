use starknet::ContractAddress;

#[starknet::interface]
trait CounterTimeTrait<TContractState> {
    fn get_counter(self: @TContractState) -> u64;
    fn increment(ref self: TContractState);
    fn get_time(self: @TContractState) -> u64;
    fn set_time(ref self: TContractState);
}

#[starknet::contract]
mod counter {
    use super::CounterTimeTrait;
    use starknet::get_block_timestamp;

    #[storage]
    struct Storage {
        counter: u64,
        timestamp: u64,
    }

    #[constructor]
    fn constructor(ref self: ContractState) {
        self.counter.write(0);
        self.timestamp.write(0);
    }

    #[external(v0)]
    impl CounterTimeImpl of CounterTimeTrait<ContractState>{
        fn get_counter(self: @ContractState) -> u64 {
            self.counter.read()
        }

        fn increment(ref self: ContractState) {
            self.counter.write(self.counter.read() + 1);
        }  

        fn get_time(self: @ContractState) -> u64 {
            self.timestamp.read()
        }

        fn set_time(ref self: ContractState) {
            self.timestamp.write(get_block_timestamp());
        }
    }
}