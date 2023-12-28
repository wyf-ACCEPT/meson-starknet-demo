use alexandria_bytes::bytes::BytesTrait;
use debug::PrintTrait;
use meson_starknet::utils::MesonHelpers;
use meson_starknet::utils::MesonConstants;

// #[test]
// #[available_gas(20000000)]
// fn test_get_swap_id() {
//     let encodedSwap = 0x01001dcd6500c00000000000f677815c000000000000634dcb98027d0102ca21;
//     let initiator = 0x2ef8a51f8ff129dbb874a0efb021702f59c1b211_u256.into();
//     let swap_id = MesonHelpers::_getSwapId(encodedSwap, initiator);
//     assert(swap_id == 0xe3a84cd4912a01989c6cd24e41d3d94baf143242fbf1da26eb7eac08c347b638, 'Failed');
// }

// #[test]
// #[available_gas(20000000)]
// fn test_get_header() {
//     let header1 = MesonConstants::_getTronSignHeaderBytes(false, false);
//     header1.size.print();
//     let (_, data) = header1.read_u128_packed(0, 9);
//     data.print();
//     let (_, data) = header1.read_u128_packed(9, 16);
//     data.print();
//     let (_, data) = header1.read_u128_packed(25, 16);
//     data.print();
// }