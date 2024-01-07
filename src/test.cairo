
#[cfg(test)]
mod tests {
    use starknet::get_block_timestamp;
    use snforge_std::{ ContractClassTrait, declare, start_prank };
    use meson_starknet::interface::MesonSwapTraitDispatcherTrait;
    use meson_starknet::interface::MesonSwapTraitDispatcher;
    use debug::PrintTrait;

    #[test]
    fn call_and_invoke() {
        let admin = starknet::contract_address_const::<0xab>();

        let contract = declare('Meson');
        let contract_address = contract.deploy(@array![admin.into()]).unwrap();
        let dispatcher = MesonSwapTraitDispatcher { contract_address };

        let timestamp = get_block_timestamp();
        timestamp.print();
        // assert(get_block_timestamp() == 1, 'time error!');

        // dispatcher.verifyEncodedSwap();

        // // Invoke another function to modify the storage state
        // dispatcher.increase_balance(100);

        // // Validate the transaction's effect
        // let balance = dispatcher.get_balance();
        // assert(balance == 100, 'balance == 100');
    }


}