use utils::MesonConfig;

//   /// @notice Decode `version` from `encodedSwap`
//   /// See variable `_postedSwaps` in `MesonSwap.sol` for the defination of `encodedSwap`
//   function _versionFrom(uint256 encodedSwap) internal pure returns (uint8) {
//     return uint8(encodedSwap >> 248);
//   }

//   /// @notice Decode `amount` from `encodedSwap`
//   /// See variable `_postedSwaps` in `MesonSwap.sol` for the defination of `encodedSwap`
//   function _amountFrom(uint256 encodedSwap) internal pure returns (uint256) {
//     return (encodedSwap >> 208) & 0xFFFFFFFFFF;
//   }

//   /// @notice Calculate the service fee from `encodedSwap`
//   /// See variable `_postedSwaps` in `MesonSwap.sol` for the defination of `encodedSwap`
//   function _serviceFee(uint256 encodedSwap) internal pure returns (uint256) {
//     uint256 minFee = _inTokenIndexFrom(encodedSwap) >= 191 ? SERVICE_FEE_MINIMUM_CORE : SERVICE_FEE_MINIMUM;
//     // Default to `serviceFee` = 0.05% * `amount`
//     uint256 fee = _amountFrom(encodedSwap) * SERVICE_FEE_RATE / 10000;
//     return fee > minFee ? fee : minFee;
//   }

fn _versionFrom(encodedSwap: u256) -> u8 {
    encodedSwap.shr(248).as_u8()
}

#[test]
fn test_version_from() {
    let encoded_swap = u256::from_dec_str("340282366920938463463374607431768211455").unwrap();
    assert_eq!(_versionFrom(encoded_swap), 0);
}