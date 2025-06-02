use starknet::ContractAddress;

#[derive(Drop, Debug, PartialEq, starknet::Event)]
pub struct PremiumManagerTransferred {
    pub prevPremiumManager: ContractAddress,
    pub newPremiumManager: ContractAddress,
}

#[derive(Drop, Debug, PartialEq, starknet::Event)]
pub struct PoolRegistered {
    pub poolIndex: u64,
    pub owner: ContractAddress,
}

#[derive(Drop, Debug, PartialEq, starknet::Event)]
pub struct PoolAuthorizedAddrAdded {
    pub poolIndex: u64,
    pub addr: ContractAddress,
}

#[derive(Drop, Debug, PartialEq, starknet::Event)]
pub struct PoolAuthorizedAddrRemoved {
    pub poolIndex: u64,
    pub addr: ContractAddress,
}

#[derive(Drop, Debug, PartialEq, starknet::Event)]
pub struct PoolOwnerTransferred {
    pub poolIndex: u64,
    pub prevOwner: ContractAddress,
    pub newOwner: ContractAddress,
}

#[derive(Drop, Debug, PartialEq, starknet::Event)]
pub struct PoolDeposited {
    pub poolTokenIndex: u64,
    pub amount: u256,
}

#[derive(Drop, Debug, PartialEq, starknet::Event)]
pub struct PoolWithdrawn {
    pub poolTokenIndex: u64,
    pub amount: u256,
}

#[derive(Drop, Debug, PartialEq, starknet::Event)]
pub struct SwapPosted {
    pub encodedSwap: u256,
}

#[derive(Drop, Debug, PartialEq, starknet::Event)]
pub struct SwapBonded {
    pub encodedSwap: u256,
}

#[derive(Drop, Debug, PartialEq, starknet::Event)]
pub struct SwapCancelled {
    pub encodedSwap: u256,
}

#[derive(Drop, Debug, PartialEq, starknet::Event)]
pub struct SwapExecuted {
    pub encodedSwap: u256,
}

#[derive(Drop, Debug, PartialEq, starknet::Event)]
pub struct SwapLocked {
    pub encodedSwap: u256,
}

#[derive(Drop, Debug, PartialEq, starknet::Event)]
pub struct SwapUnlocked {
    pub encodedSwap: u256,
}

#[derive(Drop, Debug, PartialEq, starknet::Event)]
pub struct SwapReleased {
    pub encodedSwap: u256,
}