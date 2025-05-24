# Smart Contract Passkeys

A cross-chain token bridge implementation using Account Abstraction and Teleporter for secure and efficient token transfers between different blockchain networks.

## Overview

This project implements a cross-chain token bridge that allows users to:

- Transfer tokens between different blockchain networks
- Execute swaps through TraderJoe DEX
- Handle cross-chain messaging using Teleporter
- Manage fees and collateral for cross-chain operations

## Features

- **Cross-Chain Token Transfers**: Seamlessly transfer tokens between different blockchain networks
- **DEX Integration**: Built-in integration with TraderJoe for token swaps
- **Account Abstraction**: Enhanced security and user experience through ERC-4337
- **Fee Management**: Configurable fee system with basis points
- **Collateral Management**: Secure handling of cross-chain collateral

## Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation)
- Access to blockchain RPC endpoints

## Installation

1. Clone the repository:

```bash
git clone https://github.com/BIG-Labs/dumb-contract
cd dumb-contract
```

2. Install dependencies:

```bash
forge install
```

## Configuration

1. Set up your environment variables:

```bash
cp .env.example .env
```

2. Configure the following in your `.env` file:

- `PRIVATE_KEY`: Your deployer private key

## Usage

### Building the Contracts

```bash
forge build
```

### Running Tests

```bash
forge test
```

### Deploying

```bash
forge script script/DeployRouter.s.sol:DeployRouter --rpc-url <your_rpc_url> --private-key <your_private_key> --broadcast
```

### Interacting with the Contract

Start a cross-chain transfer:

```solidity
router.start(
    token,
    amount,
    instructions,
    receiver
);
```

## Architecture

The project consists of several key components:

- **Router**: Main contract handling cross-chain transfers and swaps
- **TokenHome**: Manages token transfers on the source chain
- **TokenRemote**: Handles token reception on the destination chain
- **Teleporter**: Handles cross-chain messaging

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For support, please open an issue in the GitHub repository or contact the maintainers.

## Acknowledgments

- [Foundry](https://book.getfoundry.sh/)
- [TraderJoe](https://lfj.gg/)
- [Teleporter](https://github.com/ava-labs/icm-contracts)
