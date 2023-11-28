use core::traits::TryInto;
// #[test]
// fn call_and_invoke() {
//     // Declare and deploy the contract
//     let contract = declare('HelloStarknet');
//     let contract_address = contract.deploy(@ArrayTrait::new()).unwrap();

//     // Instantiate a Dispatcher object for contract interactions
//     let dispatcher = IHelloStarknetDispatcher { contract_address };

//     // Invoke a contract's view function
//     let balance = dispatcher.get_balance();
//     assert(balance == 0, 'balance == 0');

//     // Invoke another function to modify the storage state
//     dispatcher.increase_balance(100);

//     // Validate the transaction's effect
//     let balance = dispatcher.get_balance();
//     assert(balance == 100, 'balance == 100');
// }

use debug::PrintTrait;
use starknet::contract_address_const;
use snforge_std::{ declare, ContractClassTrait };
use openzeppelin::token::erc20::interface::{IERC20Dispatcher, IERC20DispatcherTrait};
use meson_starknet_demo::htlc::IHashTimeLockDispatcher;

#[test]
fn test_journey() {
    let recipient = contract_address_const::<0x01>();
    let token_declare = declare('MyUSDToken');
    let token = token_declare.deploy(
        @array![recipient.into()],
    ).unwrap();
    let htlc_declare = declare('HashTimeLock');
    let htlc = htlc_declare.deploy(
        @array![token.into()],
    ).unwrap();

    let token_dispatcher = IERC20Dispatcher { contract_address: token };
    let htlc_dispatcher = IHashTimeLockDispatcher { contract_address: htlc };

    let balance = token_dispatcher.balance_of(recipient);
    // assert(balance == 0, 'balance == 0');
    let balance_felt: felt252 = balance.try_into().unwrap();
    balance_felt.print();
}