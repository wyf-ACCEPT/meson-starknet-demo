use starknet::ContractAddress;
use super::MesonConstants;

//   function getShortCoinType() external pure returns (bytes2) 
//   function _getSwapId(uint256 encodedSwap, address initiator) internal pure returns (bytes32)

fn _versionFrom(encodedSwap: u256) -> u8 {
    (encodedSwap / MesonConstants::POW_2_248).try_into().unwrap()
}

fn _amountFrom(encodedSwap: u256) -> u256 {
    (encodedSwap / MesonConstants::POW_2_208) & 0xFFFFFFFFFF
}

// fn _serviceFee(encodedSwap: u256) -> u256 {
//     let minFee = if _inTokenIndexFrom(encodedSwap) >= 191 {
//         MesonConstants::SERVICE_FEE_MINIMUM_CORE
//     } else {
//         MesonConstants::SERVICE_FEE_MINIMUM
//     };
//     let fee = _amountFrom(encodedSwap) * MesonConstants::SERVICE_FEE_RATE / 10000;
//     if fee > minFee {
//         fee
//     } else {
//         minFee
//     }
// }

fn _feeForLp(encodedSwap: u256) -> u256 {
    (encodedSwap / MesonConstants::POW_2_88) & 0xFFFFFFFFFF
}

//   /// @notice Decode `salt` from `encodedSwap`
//   /// See variable `_postedSwaps` in `MesonSwap.sol` for the defination of `encodedSwap`
//   function _saltFrom(uint256 encodedSwap) internal pure returns (uint80) {
//     return uint80(encodedSwap >> 128);
//   }

//   /// @notice Decode data from `salt`
//   /// See variable `_postedSwaps` in `MesonSwap.sol` for the defination of `encodedSwap`
//   function _saltDataFrom(uint256 encodedSwap) internal pure returns (uint64) {
//     return uint64(encodedSwap >> 128);
//   }

fn _saltDataFrom(encodedSwap: u256) -> u64 {
    ((encodedSwap / MesonConstants::POW_2_128) & 0xffffffffffffffff).try_into().unwrap()
}

//   /// @notice Whether the swap should release to a 3rd-party integrated dapp contract
//   /// See method `release` in `MesonPools.sol` for more details
//   function _willTransferToContract(uint256 encodedSwap) internal pure returns (bool) {
//     return (encodedSwap & 0x8000000000000000000000000000000000000000000000000000) == 0;
//   }

//   /// @notice Whether the swap needs to pay service fee
//   /// See method `release` in `MesonPools.sol` for more details about the service fee
//   function _feeWaived(uint256 encodedSwap) internal pure returns (bool) {
//     return (encodedSwap & 0x4000000000000000000000000000000000000000000000000000) > 0;
//   }
  
//   /// @notice Whether the swap was signed in the non-typed manner (usually by hardware wallets)
//   function _signNonTyped(uint256 encodedSwap) internal pure returns (bool) {
//     return (encodedSwap & 0x0800000000000000000000000000000000000000000000000000) > 0;
//   }

//   function _swapForCoreToken(uint256 encodedSwap) internal pure returns (bool) {
//     return !_willTransferToContract(encodedSwap) && (_outTokenIndexFrom(encodedSwap) < 191) &&
//       ((encodedSwap & 0x0400000000000000000000000000000000000000000000000000) > 0);
//   }

//   function _amountForCoreTokenFrom(uint256 encodedSwap) internal pure returns (uint256) {
//     if (_swapForCoreToken(encodedSwap)) {
//       return ((encodedSwap >> 160) & 0x00000FFF) * 1e5;
//     }
//     return 0;
//   }

//   function _coreTokenAmount(uint256 encodedSwap) internal pure returns (uint256) {
//     uint256 amountForCore = _amountForCoreTokenFrom(encodedSwap);
//     if (amountForCore > 0) {
//       return amountForCore * CORE_TOKEN_PRICE_FACTOR / ((encodedSwap >> 172) & 0xFFFFF);
//     }
//     return 0;
//   }

//   function _amountToLock(uint256 encodedSwap) internal pure returns (uint256) {
//     return _amountFrom(encodedSwap) - _feeForLp(encodedSwap) - _amountForCoreTokenFrom(encodedSwap);
//   }

//   /// @notice Decode `expireTs` from `encodedSwap`
//   /// See variable `_postedSwaps` in `MesonSwap.sol` for the defination of `encodedSwap`
//   function _expireTsFrom(uint256 encodedSwap) internal pure returns (uint256) {
//     return (encodedSwap >> 48) & 0xFFFFFFFFFF;
//     // [Suggestion]: return uint40(encodedSwap >> 48);
//   }

//   /// @notice Decode the initial chain (`inChain`) from `encodedSwap`
//   /// See variable `_postedSwaps` in `MesonSwap.sol` for the defination of `encodedSwap`
//   function _inChainFrom(uint256 encodedSwap) internal pure returns (uint16) {
//     return uint16(encodedSwap >> 8);
//   }

//   /// @notice Decode the token index of initial chain (`inToken`) from `encodedSwap`
//   /// See variable `_postedSwaps` in `MesonSwap.sol` for the defination of `encodedSwap`
//   function _inTokenIndexFrom(uint256 encodedSwap) internal pure returns (uint8) {
//     return uint8(encodedSwap);
//   }

//   /// @notice Decode the target chain (`outChain`) from `encodedSwap`
//   /// See variable `_postedSwaps` in `MesonSwap.sol` for the defination of `encodedSwap`
//   function _outChainFrom(uint256 encodedSwap) internal pure returns (uint16) {
//     return uint16(encodedSwap >> 32);
//   }

//   /// @notice Decode the token index of target chain (`outToken`) from `encodedSwap`
//   /// See variable `_postedSwaps` in `MesonSwap.sol` for the defination of `encodedSwap`
//   function _outTokenIndexFrom(uint256 encodedSwap) internal pure returns (uint8) {
//     return uint8(encodedSwap >> 24);
//   }

//   function _tokenType(uint8 tokenIndex) internal pure returns (uint8) {
//     if (tokenIndex >= 192) {
//       // Non stablecoins
//       return tokenIndex / 4;
//     } else if (tokenIndex < 65) {
//       // Stablecoins
//       return 0;
//     }
//     revert("Token index not allowed for swapping");
//   }

//   /// @notice Decode `outToken` from `encodedSwap`, and encode it with `poolIndex` to `poolTokenIndex`.
//   /// See variable `_balanceOfPoolToken` in `MesonStates.sol` for the defination of `poolTokenIndex`
//   function _poolTokenIndexForOutToken(uint256 encodedSwap, uint40 poolIndex) internal pure returns (uint48) {
//     return uint48((encodedSwap & 0xFF000000) << 16) | poolIndex;
//   }

//   /// @notice Decode `initiator` from `postedSwap`
//   /// See variable `_postedSwaps` in `MesonSwap.sol` for the defination of `postedSwap`
//   function _initiatorFromPosted(uint200 postedSwap) internal pure returns (address) {
//     return address(uint160(postedSwap >> 40));
//   }
