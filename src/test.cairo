// mod test_helpers;
// mod test_htlc;

// #[starknet::interface]
// trait IGrandpa<TContractState> {
//     fn set_grandpa(ref self: TContractState, grandpa: u64);
//     fn get_grandpa(self: @TContractState) -> u64;
// }

// #[starknet::interface]
// trait IFather<TContractState> {
//     fn set_father(ref self: TContractState, father: u64);
//     fn get_father(self: @TContractState) -> u64;
// }

// #[starknet::interface]
// trait IUncle<TContractState> {
//     fn set_uncle(ref self: TContractState, uncle: u64);
//     fn get_uncle(self: @TContractState) -> u64;
// }

// #[starknet::interface]
// trait ISon<TContractState> {
//     fn set_son(ref self: TContractState, son: u64);
//     fn get_son(self: @TContractState) -> u64;
// }

// #[starknet::component]
// mod GrandpaComponent {
//     use super::IGrandpa;

//     #[storage]
//     struct Storage {
//         grandpa: u64
//     }

//     #[event]
//     #[derive(Drop, starknet::Event)]
//     enum Event {
//         Transfer: Transfer,
//     }

//     #[derive(Drop, starknet::Event)]
//     struct Transfer {}

//     #[embeddable_as(GrandpaImpl)]
//     impl Grandpa<
//         TContractState, +HasComponent<TContractState>
//     > of IGrandpa<ComponentState<TContractState>> {
//         fn set_grandpa(ref self: ComponentState<TContractState>, grandpa: u64) {
//             self.grandpa.write(grandpa);
//         }

//         fn get_grandpa(self: @ComponentState<TContractState>) -> u64 {
//             self.grandpa.read()
//         }
        
//     }
// }

// #[starknet::contract]
// mod FatherContract {
//     use super::IFather;

//     component!(path: super::GrandpaComponent, storage: grandpaStore, event: grandpaEvent);

//     #[storage]
//     struct Storage {
//         #[substorage(v0)]
//         grandpaStore: super::GrandpaComponent::Storage,
//     }

//     #[event]
//     #[derive(Drop, starknet::Event)]
//     enum Event {
//         #[flat]
//         grandpaEvent: super::GrandpaComponent::Event
//     }

//     // #[external(v0)]
//     // impl FatherImpl of super::IFather<ContractState> {
//     //     fn set_father(ref self: ContractState, father: u64) {
//     //         self.grandpaStore.grandpa.write(father);
//     //     }

//     //     fn get_father(self: @ContractState) -> u64 {
//     //         self.grandpaStore.grandpa.read()
//     //     }
//     // }
// }

// // use FatherContract::StorageMemberAccessTrait;
// // use FatherContract::StorageMapMemberAccessTrait;

// // #[external(v0)]
// // impl FatherImpl of IFather<FatherContract::ContractState> {
// //     fn set_father(ref self: FatherContract::ContractState, father: u64) {
// //         self.grandpaStore.grandpa.write(father);
// //     }

// //     fn get_father(self: @FatherContract::ContractState) -> u64 {
// //         self.grandpaStore.grandpa.read()
// //     }
// // }

// #[starknet::interface]
// trait ISister<TContractState> {
//     fn set_sister(ref self: TContractState, sister: u64);
//     fn get_sister(self: @TContractState) -> u64;
// }

// #[starknet::contract]
// mod SisterContract {
//     #[storage]
//     struct Storage {
//         sister: u64
//     }

//     // #[abi(embed_v0)]
//     // impl SisterImpl = super::SisterImpl;
//     // impl SisterImpl = super::SisterImpl;

//     // #[external(v0)]
//     // impl SisterImpl = super::SisterImpl;
//     // use super::SisterImpl;


//     // #[external(v0)]
//     // #[generate_trait]
//     // impl SisterImpl of SisterTrait {
//     //     fn set_sister(ref self: ContractState, sister: u64) {
//     //         self.sister.write(sister);
//     //     }

//     //     fn get_sister(self: @ContractState) -> u64 {
//     //         self.sister.read()
//     //     }
//     // }
    
// }

// use SisterContract::sisterContractMemberStateTrait;

// #[external(v0)]
// impl SisterImpl of ISister<SisterContract::ContractState> {
//     fn set_sister(ref self: SisterContract::ContractState, sister: u64) {
//         self.sister.write(sister);
//     }

//     fn get_sister(self: @SisterContract::ContractState) -> u64 {
//         self.sister.read()
//     }
// }

// // #[external(v0)]
// // #[generate_trait]
// // impl SisterImpl of SisterTrait {
// //     fn set_sister(ref self: SisterContract::ContractState, sister: u64) {
// //         self.sister.write(sister);
// //     }

// //     fn get_sister(self: @SisterContract::ContractState) -> u64 {
// //         self.sister.read()
// //     }
// // }

// // #[starknet::component]
// // mod SisterImplComponent {
// //     #[storage]
// //     struct Storage {}

// //     #[embeddable_as(SisterImpl)]
// //     impl Sister<
// //         TContractState, +HasComponent<TContractState>
// //     > of super::ISister<TContractState> {
// //         fn set_sister(ref self: TContractState, sister: u64) {
// //             self.sister.write(sister);
// //         }

// //         fn get_sister(self: @TContractState) -> u64 {
// //             self.sister.read()
// //         }
// //     }
// // }



// // mod SonContract {
// //     use super::FatherContract;
// //     use super::GrandpaComponent;

// //     #[storage]
// //     struct Storage {
// //         son: u64
// //     }

// //     #[external(v0)]
// //     #[generate_trait]
// //     impl Private of PrivateTrait {
// //         fn set_son_and_grandpa(
// //             ref fatherStore: FatherContract::ContractState,
// //             grandpa: u64
// //         ) {
// //             // fatherStore.grandpaStore.grandpa.write(grandpa);
            
// //         }
// //     }
// // }