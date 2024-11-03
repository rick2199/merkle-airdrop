// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {BagelToken} from "src/BagelToken.sol";
import {MerkleAirdrop} from "src/MerkleAirdrop.sol";

contract DeployMerkleAirdrop is Script {
    bytes32 public constant MERKLE_ROOT = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    uint256 public constant AMOUNT_TO_TRANSFER = 4 * 25 * 1e18;

    function _deployMerkleAirdrop() private returns (MerkleAirdrop, BagelToken) {
        vm.startBroadcast();
        BagelToken token = new BagelToken();
        MerkleAirdrop airdrop = new MerkleAirdrop(MERKLE_ROOT, token);
        token.mint(token.owner(), AMOUNT_TO_TRANSFER);
        token.transfer(address(airdrop), AMOUNT_TO_TRANSFER);
        vm.stopBroadcast();
        return (airdrop, token);
    }

    function run() external returns (MerkleAirdrop, BagelToken) {
        return _deployMerkleAirdrop();
    }
}
