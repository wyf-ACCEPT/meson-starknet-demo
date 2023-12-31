#[starknet::contract]
mod MyUSDToken {
    use starknet::{ContractAddress, get_caller_address};
    use openzeppelin::token::erc20::ERC20Component;

    component!(path: ERC20Component, storage: erc20, event: ERC20Event);

    #[abi(embed_v0)]
    impl ERC20Impl = ERC20Component::ERC20Impl<ContractState>;
    #[abi(embed_v0)]
    impl ERC20MetadataImpl = ERC20Component::ERC20MetadataImpl<ContractState>;
    impl ERC20InternalImpl = ERC20Component::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        erc20: ERC20Component::Storage
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        ERC20Event: ERC20Component::Event
    }

    #[constructor]
    fn constructor(
        ref self: ContractState,
        recipient: ContractAddress,
    ) {
        let name = 'MyUSDToken';
        let symbol = 'MUSD';

        self.erc20.initializer(name, symbol);
        self.erc20._mint(recipient, 1_000_000_000_000000000000000000);
    }
}