// Constant values used in the Meson protocol.

const MESON_PROTOCOL_VERSION: u8 = 1;

// See https://github.com/satoshilabs/slips/blob/master/slip-0044.md
const SHORT_COIN_TYPE: u16 = 0x232c;

const MAX_SWAP_AMOUNT: u256 = 100_000_000_000_000; // 100,000.000000 = 100k
const SERVICE_FEE_RATE: u256 = 5; // service fee = 5 / 10000 = 0.05%
const SERVICE_FEE_MINIMUM: u256 = 500_000; // min $0.5
const SERVICE_FEE_MINIMUM_CORE: u256 = 500; // min 0.0005 ETH ~ $1

const CORE_TOKEN_PRICE_FACTOR: u256 = 10;

const MIN_BOND_TIME_PERIOD: u256 = consteval_int!(1 * 60 * 60); // 1 hours
const MAX_BOND_TIME_PERIOD: u256 = consteval_int!(2 * 60 * 60); // 2 hours
const LOCK_TIME_PERIOD: u256 = consteval_int!(40 * 60); // 40 minutes

const ETH_SIGN_HEADER: felt252= '\x19Ethereum Signed Message:\n32';
const ETH_SIGN_HEADER_52: felt252 = '\x19Ethereum Signed Message:\n52';
const TRON_SIGN_HEADER: felt252 = '\x19TRON Signed Message:\n32\n';
const TRON_SIGN_HEADER_33: felt252 = '\x19TRON Signed Message:\n33\n';
const TRON_SIGN_HEADER_53: felt252 = '\x19TRON Signed Message:\n53\n';

// const REQUEST_TYPE_HASH: felt252 = keccak256('bytes32 Sign to request a swap on Meson (Testnet)');
// const RELEASE_TYPE_HASH: felt252 = keccak256('bytes32 Sign to release a swap on Meson (Testnet)address Recipient');
// const RELEASE_TO_TRON_TYPE_HASH: felt252 = keccak256('bytes32 Sign to release a swap on Meson (Testnet)address Recipient (tron address in hex format)');

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