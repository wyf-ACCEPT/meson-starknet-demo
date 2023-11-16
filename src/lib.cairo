#[starknet::contract]
mod hello {
    #[storage]
    struct Storage {
        name: felt252,
    }

    #[constructor]
    fn constructor(ref self: ContractState, name: felt252) {
        self.name.write(name);
    }

    #[external(v0)]
    fn get_name(self: @ContractState) -> felt252 {
        self.name.read()
    }
    
    #[external(v0)]
    fn set_name(ref self: ContractState, name: felt252) {
        let previous = self.name.read();
        self.name.write(name);
    }
}