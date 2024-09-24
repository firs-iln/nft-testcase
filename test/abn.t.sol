// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../src/abn.sol";

contract ABNTest is Test {
    address owner;
    ABN nft;

    uint256 constant MAX_SUPPLY = 100;
    uint256 constant MAX_PER_ADDRESS = 6;
    uint256 constant TOKEN_PRICE = 0.001 ether;
    uint256 constant MAX_TOKENS_PER_MINT = 3;

    address soloTester;

    function setUp() public {
        nft = new ABN("ipfs://mockCID/", MAX_SUPPLY);

        owner = makeAddr("owner");
        vm.deal(owner, 1 ether);

        soloTester = address(100);
        vm.deal(soloTester, 5 ether);
    }

    function testMintSuccessfully() public {
        vm.prank(soloTester);
        nft.mint{value: 0.001 ether}(1, soloTester);
        assertEq(nft.balanceOf(soloTester), 1);
        assertEq(nft.ownerOf(1), soloTester);
    }

    function testCannotMintMoreThanThreeTokens() public {
        vm.prank(soloTester);
        vm.expectRevert(bytes("Cannot mint more than 3 tokens at a time"));
        nft.mint{value: 0.004 ether}(4, soloTester);
    }

    function testCannotExceedTotalSupply() public {
        for (uint256 i = 0; i < 17; i++) {
            address addr = vm.addr(i + 1);
            vm.deal(addr, 1 ether);
            nft.mint{value: 0.003 ether}(3, addr);
            // we wanna mint exactly 100 tokens
            if (i < 16) {
                nft.mint{value: 0.003 ether}(3, addr);
            } else {
                nft.mint{value: 0.001 ether}(1, addr);
            }
        }

        vm.prank(soloTester);
        vm.expectRevert(bytes("Exceeds maximum supply"));
        nft.mint{value: 0.001 ether}(1, soloTester);
    }

    function testCannotExceedTokensPerAddress() public {
        vm.prank(soloTester);
        nft.mint{value: 0.003 ether}(3, soloTester);
        vm.prank(soloTester);
        nft.mint{value: 0.003 ether}(3, soloTester);
        vm.prank(soloTester);
        vm.expectRevert(bytes("Recipient cannot own more than 6 tokens"));
        nft.mint{value: 0.001 ether}(1, soloTester); // attempt to mint 1 more
    }

    function testMintInsufficientPayment() public {
        vm.prank(soloTester);
        vm.expectRevert(bytes("Ether value sent is not correct"));
        nft.mint{value: 0.0005 ether}(1, soloTester);
    }

    function testOnlyOwnerCanWithdraw() public {
        vm.prank(soloTester);
        vm.expectRevert();
        nft.withdraw(0.001 ether, payable(soloTester));
    }

    function testWithdrawFunds() public {
        vm.prank(soloTester);
        nft.mint{value: 0.002 ether}(2, soloTester);
        uint256 initialBalance = owner.balance;
        nft.withdraw(0.002 ether, payable(owner));
        uint256 finalBalance = owner.balance;
        assertEq(finalBalance, initialBalance + 0.002 ether);
    }
}
