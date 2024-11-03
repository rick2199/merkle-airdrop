# Merkle Airdrop Project

![Tests](https://github.com/dmfxyz/murky/actions/workflows/run_tests.yml/badge.svg?event=push)
![Slither](https://github.com/dmfxyz/murky/actions/workflows/slither.yml/badge.svg?event=push)

## Overview

The Merkle Airdrop project provides a robust solution for generating and verifying Merkle proofs in Solidity. It includes contracts that can generate Merkle roots and proofs, as well as perform inclusion verification. This project is ideal for implementing airdrops, where users can claim tokens by proving their inclusion in a Merkle tree.

### Key Features

1. **Merkle Tree Implementations**:
   - **`Merkle.sol`**: Implements the tree as a [Full Binary Tree](https://xlinux.nist.gov/dads/HTML/fullBinaryTree.html).
   - **`CompleteMerkle.sol`**: Uses [Complete Binary Trees](https://xlinux.nist.gov/dads/HTML/completeBinaryTree.html), compatible with some external libraries.

2. **Customizable Hashing**:
   - Default implementations use sorted concatenation-based hashing.
   - Custom hashing functions can be implemented by inheriting from `MurkyBase.sol`.

### Building Locally

To run the project locally, follow these steps:

1. Clone the repository.
2. Install dependencies using `make install`.
3. Run tests with `forge test`.

### Testing

The project includes tests with standardized data. Ensure all changes pass these tests. Slither analysis must also pass.

### Note

The code is not audited yet. Please conduct your own due diligence if you plan to use this code in production.

