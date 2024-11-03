// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

/// @title MerkleAirdrop
/// @notice This contract allows users to claim tokens from a Merkle airdrop.
/// @dev Inherits from EIP712 for signature verification.
contract MerkleAirdrop is EIP712 {
    using SafeERC20 for IERC20;

    error MerkleAirdrop__InvalidProof();
    error MerkleAirdrop__AlreadyClaimed();
    error MerkleAirdrop__InvalidSignature();

    bytes32 private immutable i_merkleRoot;
    IERC20 private immutable i_airdropToken;
    mapping(address claimer => bool claimed) private s_hasClaimed;
    bytes32 private constant MESSAGE_TYPEHASH = keccak256("AirdropClaim(address account, uint256 amount)");

    struct AirdropClaim {
        address account;
        uint256 amount;
    }

    /// @notice Event emitted when a claim is successfully made.
    /// @param account The address of the account that claimed the airdrop.
    /// @param amount The amount of tokens claimed.
    event Claim(address indexed account, uint256 amount);

    /// @notice Constructor to initialize the MerkleAirdrop contract.
    /// @param merkleRoot The Merkle root of the airdrop.
    /// @param airdropToken The ERC20 token being airdropped.
    constructor(bytes32 merkleRoot, IERC20 airdropToken) EIP712("MerkleAirdrop", "1") {
        i_merkleRoot = merkleRoot;
        i_airdropToken = airdropToken;
    }

    /// @notice Allows a user to claim their airdrop.
    /// @param account The address of the account claiming the airdrop.
    /// @param amount The amount of tokens to claim.
    /// @param merkleProof The Merkle proof to verify the claim.
    /// @param v The recovery byte of the signature.
    /// @param r Half of the ECDSA signature pair.
    /// @param s Half of the ECDSA signature pair.
    function claim(address account, uint256 amount, bytes32[] calldata merkleProof, uint8 v, bytes32 r, bytes32 s)
        external
    {
        if (s_hasClaimed[account]) {
            revert MerkleAirdrop__AlreadyClaimed();
        }
        // Check for signature
        if (!_isValidSignature(account, getMessageHash(account, amount), v, r, s)) {
            revert MerkleAirdrop__InvalidSignature();
        }
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(account, amount))));
        if (!MerkleProof.verify(merkleProof, i_merkleRoot, leaf)) {
            revert MerkleAirdrop__InvalidProof();
        }
        s_hasClaimed[account] = true;
        emit Claim(account, amount);
        i_airdropToken.safeTransfer(account, amount);
    }

    /// @notice Generates the message hash for a claim.
    /// @param account The address of the account.
    /// @param amount The amount of tokens.
    /// @return The message hash.
    function getMessageHash(address account, uint256 amount) public view returns (bytes32) {
        return
            _hashTypedDataV4(keccak256(abi.encode(MESSAGE_TYPEHASH, AirdropClaim({account: account, amount: amount}))));
    }

    /// @notice Returns the Merkle root of the airdrop.
    /// @return The Merkle root.
    function getMerkleRoot() external view returns (bytes32) {
        return i_merkleRoot;
    }

    /// @notice Returns the ERC20 token being airdropped.
    /// @return The ERC20 token.
    function getAirdropToken() external view returns (IERC20) {
        return i_airdropToken;
    }

    /// @notice Verifies if a signature is valid.
    /// @param account The address of the account.
    /// @param digest The message digest.
    /// @param v The recovery byte of the signature.
    /// @param r Half of the ECDSA signature pair.
    /// @param s Half of the ECDSA signature pair.
    /// @return True if the signature is valid, false otherwise.
    function _isValidSignature(address account, bytes32 digest, uint8 v, bytes32 r, bytes32 s)
        internal
        pure
        returns (bool)
    {
        (address actualSigner,,) = ECDSA.tryRecover(digest, v, r, s);
        return actualSigner == account;
    }
}
