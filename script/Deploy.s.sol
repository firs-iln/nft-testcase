// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/ABN.sol";

contract Deploy is Script {
    function run() external {
        string memory baseTokenURI = concat(concat("ipfs://", vm.envString("CID")), "/");
        uint256 maxSupply = vm.envUint("MAX_SUPPLY");
        vm.startBroadcast();

        ABN abn = new ABN(baseTokenURI, maxSupply);

        console.log("Contract deployed at:", address(abn));

        vm.stopBroadcast(); 
    }

    function concat(string memory a, string memory b) internal pure returns (string memory) {
        return string(abi.encodePacked(a, b));
    }
}
