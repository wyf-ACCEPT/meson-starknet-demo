use core::option::OptionTrait;
use starknet::{ContractAddress, EthAddress};
use super::MesonConstants;
use alexandria_bytes::{Bytes, BytesTrait};
use starknet::verify_eth_signature;
use starknet::secp256_trait::signature_from_vrs;

// Note that there's no `<<` or `>>` operator in cairo.
const POW_2_255: u256 = 0x8000000000000000000000000000000000000000000000000000000000000000;
const POW_2_248: u256 = 0x100000000000000000000000000000000000000000000000000000000000000;
const POW_2_208: u256 = 0x10000000000000000000000000000000000000000000000000000;
const POW_2_172: u256 = 0x10000000000000000000000000000000000000000000;
const POW_2_160: u256 = 0x10000000000000000000000000000000000000000;
const POW_2_128: u256 = 0x100000000000000000000000000000000;
const POW_2_96 : u256 = 0x1000000000000000000000000;
const POW_2_88 : u256 = 0x10000000000000000000000;
const POW_2_48 : u256 = 0x1000000000000;
const POW_2_40 : u256 = 0x10000000000;
const POW_2_32 : u256 = 0x100000000;
const POW_2_24 : u256 = 0x1000000;
const POW_2_16 : u256 = 0x10000;
const POW_2_8  : u256 = 0x100;

const U160_MAX : u256 = 0xffffffffffffffffffffffffffffffffffffffff;
const U80_MAX  : u256 = 0xffffffffffffffffffff;
const U64_MAX  : u256 = 0xffffffffffffffff;
const U40_MAX  : u256 = 0xffffffffff;
const U32_MAX  : u256 = 0xffffffff;
const U20_MAX  : u256 = 0xfffff;
const U16_MAX  : u256 = 0xffff;
const U12_MAX  : u256 = 0xfff;
const U8_MAX   : u256 = 0xff;

enum MesonErrors {
    TokenIndexNotAllowed,
    SignerCannotBeZero,
    InvalidSignature,
}

fn getShortCoinType() -> u16 {
    MesonConstants::SHORT_COIN_TYPE
}

// TODO: Test this!
fn _getSwapId(encodedSwap: u256, initiator: EthAddress) -> u256 {
    let mut bytes = BytesTrait::new_empty();
    bytes.append_u256(encodedSwap);
    let initiator_u256: u256 = initiator.address.into();
    let initiator_high_shifted = (
        (initiator_u256.high.into() % POW_2_32) * POW_2_96
    ).try_into().unwrap();
    bytes.append_u128_packed(initiator_high_shifted, 4);
    bytes.append_u128(initiator_u256.low);
    bytes.keccak()
}

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

fn _saltFrom(encodedSwap: u256) -> u128 {    // Original uint256 -> uint80
    ((encodedSwap / POW_2_128) & U80_MAX).try_into().unwrap()
}

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
        Result::Ok(tokenIndex / 4)  // Non stablecoins
    } else if tokenIndex < 65 {
        Result::Ok(0_u8)    // Stablecoins
    } else {
        Result::Err(MesonErrors::TokenIndexNotAllowed)
    }
}

fn _poolTokenIndexForOutToken(encodedSwap: u256, poolIndex: u64) -> u64 {   // original (uint256, uint40) -> uint48
    ((encodedSwap & 0xFF000000) * POW_2_16).try_into().unwrap() | poolIndex
}

fn _initiatorFromPosted(postedSwap: u256) -> EthAddress {   // original (uint200) -> address
    (postedSwap / POW_2_40).into()
}

fn _poolIndexFromPosted(postedSwap: u256) -> u64 {  // original (uint200) -> uint40
    (postedSwap & U40_MAX).try_into().unwrap()
}

fn _lockedSwapFrom(until: u256, poolIndex: u64) -> u128 {   // original (uint256, uint40) -> uint80
    ((until * POW_2_40).try_into().unwrap() | poolIndex).into()
}

fn _poolIndexFromLocked(lockedSwap: u128) -> u64 {  // original (uint80) -> uint40
    (lockedSwap.into() & U40_MAX).try_into().unwrap()
}

fn _untilFromLocked(lockedSwap: u128) -> u256 {  // original (uint80) -> uint256
    (lockedSwap.into() / POW_2_40).into()
}

fn _poolTokenIndexFrom(tokenIndex: u8, poolIndex: u64) -> u64 {     // original (uint8, uint40) -> uint48
    (tokenIndex.into() * POW_2_40).try_into().unwrap() | poolIndex
}

fn _tokenIndexFrom(poolTokenIndex: u64) -> u8 {     // original (uint48) -> uint8
    (poolTokenIndex.into() / POW_2_40).try_into().unwrap()
}

fn _poolIndexFrom(poolTokenIndex: u64) -> u64 {     // original (uint48) -> uint40
    (poolTokenIndex.into() & U40_MAX).try_into().unwrap()
}

//   function _checkRequestSignature(
//     uint256 encodedSwap,
//     bytes32 r,
//     bytes32 yParityAndS,
//     address signer
//   ) internal pure {
//     require(signer != address(0), "Signer cannot be empty address");
//     bytes32 s = yParityAndS & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
//     uint8 v = uint8((uint256(yParityAndS) >> 255) + 27);
//     require(uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0, "Invalid signature");

//     bool nonTyped = _signNonTyped(encodedSwap);
//     bytes32 digest;
//     if (_inChainFrom(encodedSwap) == 0x00c3) {
//       digest = keccak256(abi.encodePacked(nonTyped ? TRON_SIGN_HEADER_33 : TRON_SIGN_HEADER, encodedSwap));
//     } else if (nonTyped) {
//       digest = keccak256(abi.encodePacked(ETH_SIGN_HEADER, encodedSwap));
//     } else {
//       bytes32 typehash = REQUEST_TYPE_HASH;
//       assembly {
//         mstore(0, encodedSwap)
//         mstore(32, keccak256(0, 32))
//         mstore(0, typehash)
//         digest := keccak256(0, 64)
//       }
//     }
//     require(signer == ecrecover(digest, v, r, s), "Invalid signature");
//   }

//   function _checkReleaseSignature(
//     uint256 encodedSwap,
//     address recipient,
//     bytes32 r,
//     bytes32 yParityAndS,
//     address signer
//   ) internal pure {
//     require(signer != address(0), "Signer cannot be empty address");
//     bytes32 s = yParityAndS & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
//     uint8 v = uint8((uint256(yParityAndS) >> 255) + 27);
//     require(uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0, "Invalid signature");

//     bool nonTyped = _signNonTyped(encodedSwap);
//     bytes32 digest;
//     if (_inChainFrom(encodedSwap) == 0x00c3) {
//       digest = keccak256(abi.encodePacked(nonTyped ? TRON_SIGN_HEADER_53 : TRON_SIGN_HEADER, encodedSwap, recipient));
//     } else if (nonTyped) {
//       digest = keccak256(abi.encodePacked(ETH_SIGN_HEADER_52, encodedSwap, recipient));
//     } else {
//       bytes32 typehash = _outChainFrom(encodedSwap) == 0x00c3 ? RELEASE_TO_TRON_TYPE_HASH : RELEASE_TYPE_HASH;
//       assembly {
//         mstore(20, recipient)
//         mstore(0, encodedSwap)
//         mstore(32, keccak256(0, 52))
//         mstore(0, typehash)
//         digest := keccak256(0, 64)
//       }
//     }
//     require(signer == ecrecover(digest, v, r, s), "Invalid signature");
//   }


fn _checkSignature(digest: u256, r: u256, yParityAndS: u256, signer: EthAddress) {
    let s = yParityAndS & 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
    let v: u32 = (yParityAndS / POW_2_255).try_into().unwrap() + 27;

    assert(signer.address != 0, 'Signer cannot be zero!');
    assert(
        s <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0,
        'Invalid signature!'    
    );

    let signature = signature_from_vrs(v, r, s);
    verify_eth_signature(digest, signature, signer);
}