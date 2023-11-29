use starknet::ContractAddress;
use super::MesonConstants;
use super::MesonErrors::MesonErrors;

// Note that there's no `<<` or `>>` operator in cairo.
const POW_2_248: u256 = 0x100000000000000000000000000000000000000000000000000000000000000;
const POW_2_208: u256 = 0x10000000000000000000000000000000000000000000000000000;
const POW_2_172: u256 = 0x10000000000000000000000000000000000000000000;
const POW_2_160: u256 = 0x10000000000000000000000000000000000000000;
const POW_2_128: u256 = 0x100000000000000000000000000000000;
const POW_2_88 : u256 = 0x10000000000000000000000;
const POW_2_48 : u256 = 0x1000000000000;
const POW_2_40 : u256 = 0x10000000000;
const POW_2_32 : u256 = 0x100000000;
const POW_2_24 : u256 = 0x1000000;
const POW_2_8  : u256 = 0x100;

const U64_MAX: u256 = 0xffffffffffffffff;
const U40_MAX: u256 = 0xffffffffff;
const U32_MAX: u256 = 0xffffffff;
const U20_MAX: u256 = 0xfffff;
const U16_MAX: u256 = 0xffff;
const U12_MAX: u256 = 0xfff;
const U8_MAX : u256 = 0xff;


fn getShortCoinType() -> u16 {
    MesonConstants::SHORT_COIN_TYPE
}

//  TODO:
//   function _getSwapId(uint256 encodedSwap, address initiator) internal pure returns (bytes32) {
//     return keccak256(abi.encodePacked(encodedSwap, initiator));
//   }

fn _versionFrom(encodedSwap: u256) -> u8 {
    (encodedSwap / POW_2_248).try_into().unwrap()
}

fn _amountFrom(encodedSwap: u256) -> u256 {
    (encodedSwap / POW_2_208) & U40_MAX
}

fn _serviceFee(encodedSwap: u256) -> u256 {
    let minFee = if _inTokenIndexFrom(encodedSwap) >= 191 {
        MesonConstants::SERVICE_FEE_MINIMUM_CORE
    } else {
        MesonConstants::SERVICE_FEE_MINIMUM
    };
    let fee = _amountFrom(encodedSwap) * MesonConstants::SERVICE_FEE_RATE / 10000;
    if fee > minFee {
        fee
    } else {
        minFee
    }
}

fn _feeForLp(encodedSwap: u256) -> u256 {
    (encodedSwap / POW_2_88) & U40_MAX
}

// Unused function: 
//   function _saltFrom(uint256 encodedSwap) internal pure returns (uint80）

fn _saltDataFrom(encodedSwap: u256) -> u64 {
    ((encodedSwap / POW_2_128) & U64_MAX).try_into().unwrap()
}

fn _willTransferToContract(encodedSwap: u256) -> bool {
    (encodedSwap & 0x8000000000000000000000000000000000000000000000000000) == 0
}

fn _feeWaived(encodedSwap: u256) -> bool {
    (encodedSwap & 0x4000000000000000000000000000000000000000000000000000) > 0
}
  
fn _signNonTyped(encodedSwap: u256) -> bool {
    (encodedSwap & 0x0800000000000000000000000000000000000000000000000000) > 0
}

fn _swapForCoreToken(encodedSwap: u256) -> bool {
    !_willTransferToContract(encodedSwap) && (_outTokenIndexFrom(encodedSwap) < 191) &&
        (encodedSwap & 0x0400000000000000000000000000000000000000000000000000 > 0)
}

fn _amountForCoreTokenFrom(encodedSwap: u256) -> u256 {
    if _swapForCoreToken(encodedSwap) {
        ((encodedSwap / POW_2_160) & U12_MAX) * 100000
    } else {
        0
    }
}

fn _coreTokenAmount(encodedSwap: u256) -> u256 {
    let amountForCore = _amountForCoreTokenFrom(encodedSwap);
    if amountForCore > 0 {
        amountForCore * MesonConstants::CORE_TOKEN_PRICE_FACTOR / 
            ((encodedSwap / POW_2_172) & U20_MAX)
    } else {
        0
    }
}

fn _amountToLock(encodedSwap: u256) -> u256 {
    _amountFrom(encodedSwap) - _feeForLp(encodedSwap) - _amountForCoreTokenFrom(encodedSwap)
}

fn _expireTsFrom(encodedSwap: u256) -> u256 {
    (encodedSwap / POW_2_48) & U40_MAX
}

fn _inChainFrom(encodedSwap: u256) -> u16 {
    ((encodedSwap / POW_2_8) & U16_MAX).try_into().unwrap()
}

fn _inTokenIndexFrom(encodedSwap: u256) -> u8 {
    (encodedSwap & U8_MAX).try_into().unwrap()
}

fn _outChainFrom(encodedSwap: u256) -> u16 {
    ((encodedSwap / POW_2_32) & U16_MAX).try_into().unwrap()
}

fn _outTokenIndexFrom(encodedSwap: u256) -> u8 {
    ((encodedSwap / POW_2_24) & U8_MAX).try_into().unwrap()
}

fn _tokenType(tokenIndex: u8) -> Result<u8, MesonErrors> {
    if tokenIndex >= 192 {
        // Non stablecoins
        Result::Ok(tokenIndex / 4)
    } else if tokenIndex < 65 {
        // Stablecoins
        Result::Ok(0_u8)
    } else {
        Result::Err(MesonErrors::TokenIndexNotAllowed)
    }
}

// TODO
// fn _poolTokenIndexForOutToken(encodedSwap: u256, poolIndex: u64) -> u48 {
//     ((encodedSwap & 0xFF000000) << 16) | poolIndex
// }
//   function _poolTokenIndexForOutToken(uint256 encodedSwap, uint40 poolIndex) internal pure returns (uint48) {
//     return uint48((encodedSwap & 0xFF000000) << 16) | poolIndex;
//   }

//   function _initiatorFromPosted(uint200 postedSwap) internal pure returns (address) {
//     return address(uint160(postedSwap >> 40));
//   }

//   function _poolIndexFromPosted(uint200 postedSwap) internal pure returns (uint40) {
//     return uint40(postedSwap);
//   }
  
//   function _lockedSwapFrom(uint256 until, uint40 poolIndex) internal pure returns (uint80) {
//     return (uint80(until) << 40) | poolIndex;
//   }

//   function _poolIndexFromLocked(uint80 lockedSwap) internal pure returns (uint40) {
//     return uint40(lockedSwap);
//   }

//   function _untilFromLocked(uint80 lockedSwap) internal pure returns (uint256) {
//     return uint256(lockedSwap >> 40);
//   }

//   function _poolTokenIndexFrom(uint8 tokenIndex, uint40 poolIndex) internal pure returns (uint48) {
//     return (uint48(tokenIndex) << 40) | poolIndex;
//   }

//   function _tokenIndexFrom(uint48 poolTokenIndex) internal pure returns (uint8) {
//     return uint8(poolTokenIndex >> 40);
//   }

//   function _poolIndexFrom(uint48 poolTokenIndex) internal pure returns (uint40) {
//     return uint40(poolTokenIndex);
//   }