// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/ABN.sol";

contract Deploy is Script {
    function run() external {
        string memory baseTokenURI = "ipfs://" + vm.envString("CID") + "/";
        uint256 maxSupply = uint256(vm.envString("MAX_SUPPLY"));
        vm.startBroadcast();

        ABN abn = new ABN(baseTokenURI, maxSupply);

        console.log("Contract deployed at:", address(abn));

        vm.stopBroadcast(); 
    }
}
