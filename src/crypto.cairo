use starknet::ContractAddress;
use starknet::eth_address::EthAddress;

#[starknet::interface]
trait CryptoTrait<TContractState> {
    fn keccak256(self: @TContractState, encodedswap: u256) -> u256;
    fn keccak256_try(self: @TContractState) -> u256;
    fn keccak256_try2(self: @TContractState) -> u256;
    fn to_eth_address(self: @TContractState, eth_address: felt252) -> (EthAddress, EthAddress);
}


#[starknet::contract]
mod crypto {
    use core::traits::TryInto;
use core::array::ArrayTrait;

    use super::{CryptoTrait, EthAddress};
    use starknet::eth_address::{Felt252TryIntoEthAddress, EthAddressZeroable};
    use alexandria_math::keccak256;
    use alexandria_bytes::{Bytes, BytesTrait};

    #[storage]
    struct Storage {
    }

    #[constructor]
    fn constructor(ref self: ContractState) {
    }

    #[external(v0)]
    impl CryptoImpl of CryptoTrait<ContractState>{
        //  starkli call <contract_address> keccak256 <u256_low> <u256_high> 
        fn keccak256(self: @ContractState, encodedswap: u256) -> u256 {
            let mut bytes: Bytes = BytesTrait::new(0, array![]);
            bytes.append_u256(encodedswap);
            bytes.keccak()
        }

        fn keccak256_try(self: @ContractState) -> u256 {
            let mut keccak_input = array![0_u8, 0, 9];
            keccak256::keccak256(keccak_input.span())
        }

        fn keccak256_try2(self: @ContractState) -> u256 {
            let mut bytes: Bytes = BytesTrait::new(0, array![]);
            bytes.append_u256(5);
            bytes.keccak()
        }

        fn to_eth_address(self: @ContractState, eth_address: felt252) -> (EthAddress, EthAddress) {
            (
                eth_address.try_into().unwrap(),
                EthAddressZeroable::zero()
            )
        }
    }
}