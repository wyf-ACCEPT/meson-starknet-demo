use debug::PrintTrait;
use meson_starknet_demo::utils::MesonHelpers;

#[test]
fn test_get_swap_id() {
    let encodedSwap = 0x010077343470980000000000f4ae51ec0000004e20006569d96103c601232809;
    let initiator = 0xa38e94bad7c57dcd804b80ad2f2f66efbdeb1ac0_u256.into();
    let swap_id = MesonHelpers::_getSwapId(encodedSwap, initiator);
    swap_id.print();
}