# ERC-4337 Account Abstraction Implementation

A Foundry-based Solidity smart contract project implementing **ERC-4337 Account Abstraction** for programmable smart contract wallets.

## Overview

This project provides a production-ready implementation of an ERC-4337 compliant account contract that enables users to execute transactions through `UserOperation` objects without requiring an externally-owned account (EOA) as the transaction originator.

### Key Features

- **ECDSA Signature Validation**: Secure signature verification using ECDSA cryptography
- **ERC-1271 Support**: Full compliance with ERC-1271 for signature validation
- **ERC-7821 Batched Execution**: Execute multiple operations in a single transaction
- **Token Support**: Compatible with ERC-721 and ERC-1155 NFT standards
- **Upgradeable**: UUPS proxy pattern for future improvements
- **Deterministic Deployment**: Support for CREATE2-style deterministic address generation

## Project Structure

```
erc4337/
├── src/
│   └── Account.sol              # Main ERC-4337 account contract
├── test/
│   └── Account.t.sol            # Comprehensive test suite
├── script/
│   └── Account.s.sol            # Deployment script
├── foundry.toml                 # Foundry configuration
└── README.md                    # This file
```

## Quick Start

### Prerequisites

- [Foundry](https://github.com/foundry-rs/foundry) installed
- Solidity ^0.8.27
- OpenZeppelin Contracts v5.5+
- account-abstraction v0.9+

### Building

```bash
forge build
```

### Running Tests

```bash
# Run all tests
forge test

# Run with verbose output
forge test -vvv

# Run specific test
forge test --match-test test_ReceiveEther
```

### Formatting

```bash
forge fmt
```

## Deployment

### Environment Setup

Set the signer address for the account (defaults to deployer if not specified):

```bash
export SIGNER_ADDRESS="0x742d35Cc6634C0532925a3b844Bc39e7Fbf90b5a"
```

### Deploy to a Network

```bash
forge script script/Account.s.sol:AccountScript \
  --rpc-url <RPC_URL> \
  --private-key <PRIVATE_KEY> \
  --broadcast
```

Example with Sepolia:

```bash
forge script script/Account.s.sol:AccountScript \
  --rpc-url https://sepolia.infura.io/v3/<PROJECT_ID> \
  --private-key <YOUR_PRIVATE_KEY> \
  --broadcast
```

## Contract Details

### SimpleAccount

The `SimpleAccount` contract implements the core ERC-4337 functionality:

- Inherits from OpenZeppelin's `Account` base class
- Uses `SignerECDSAUpgradeable` for signature validation
- Supports batched execution via `ERC7821`
- Can receive and hold ERC-721 and ERC-1155 tokens
- Upgradeable via UUPS proxy pattern

#### Key Functions

- `initialize(address signer)` - Initialize the account with a signer address
- `isValidSignature(bytes32 hash, bytes calldata signature)` - Validate signatures per ERC-1271
- `execute()` - Execute a single transaction
- `executeBatch()` - Execute multiple transactions

## ERC-4337 Concepts

### UserOperation

A UserOperation is a transaction-like object containing:

- Sender account address
- Nonce and call data
- Gas limits and pricing information
- Signature and other validation data

### Entry Point

The central contract (`IEntryPoint`) that:

- Validates UserOperations via `validateUserOp()`
- Executes transactions via the account contract
- Manages nonce tracking and gas accounting
- Integrates with optional Paymasters for gas sponsorship

### Bundler

An off-chain service that:

- Collects UserOperations from users
- Validates operations
- Bundles them together
- Submits to the Entry Point contract

### Paymaster (Optional)

An optional contract that can sponsor gas fees for UserOperations.

## Testing

The test suite in [test/Account.t.sol](test/Account.t.sol) covers:

- Account initialization and signer setup
- ETH receive functionality
- ERC-1271 signature validation
- Proxy deployment patterns

Run tests with:

```bash
forge test -vvv
```

## Gas Optimization

Track gas usage with:

```bash
forge snapshot
```

This generates a `.gas-snapshot` file with baseline gas costs for all tests.

## Dependencies

- **@openzeppelin/contracts** - OpenZeppelin Contracts v5.5+
- **@openzeppelin/contracts-upgradeable** - Upgradeable extensions
- **account-abstraction** - ERC-4337 entry point and interfaces
- **openzeppelin-foundry-upgrades** - Proxy deployment utilities

## Development

### Code Style

- Follows Solidity style guide
- Uses Named imports
- MIT License

### Common Commands

```bash
forge build              # Compile contracts
forge test              # Run all tests
forge test -vvv         # Verbose test output
forge fmt               # Format code
forge snapshot          # Update gas snapshots
forge coverage          # Generate coverage report
```

## License

MIT License - see [LICENSE](LICENSE) file for details

## References

- [ERC-4337: Account Abstraction via Entry Point Contract specification](https://eips.ethereum.org/EIPS/eip-4337)
- [OpenZeppelin Account Contracts Documentation](https://docs.openzeppelin.com/contracts/5.x/api/account)
- [Foundry Documentation](https://book.getfoundry.sh/)
