// SPDX-License-Identifier: MIT
// compiler-options: --optimize
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";

/**
 * @title ABN - Awesome Bears NFT Collection
 * @notice This contract implements an ERC721 token for the Awesome Bears NFT collection.
 * @dev The contract allows minting of NFTs with a configurable total supply, minting limits per address, and token price.
 */
contract ABN is ERC721, Ownable {
    uint256 public maxSupply; // Total supply of NFTs, configurable via constructor or onlyOwner setter
    uint256 public constant MAX_PER_MINT = 3; // Maximum number of tokens per mint
    uint256 public constant MAX_TOKENS_PER_ADDRESS = 6; // Maximum number of tokens a single address can hold
    uint256 public totalSupply; // Current total supply of minted tokens
    uint256 public tokenPrice = 0.001 ether; // Price per token
    string private baseTokenURI; // Base URI for token metadata

    /**
     * @notice Initializes the NFT contract with a base URI and a maximum supply of tokens.
     * @dev The constructor sets the baseTokenURI and the maximum supply for the NFT collection.
     * @param baseURI The base URI for the token metadata (e.g., IPFS link).
     * @param initMaxSupply The total number of NFTs that can be minted.
     */
    constructor(string memory baseURI, uint256 initMaxSupply) ERC721("AwesomeBearsNFT", "ABN") Ownable(msg.sender) {
        require(initMaxSupply > 0, "Max supply must be greater than zero");
        baseTokenURI = baseURI;
        maxSupply = initMaxSupply;
    }

    /**
     * @notice Mints the specified number of NFTs to the recipient address.
     * @dev Requires that the number of tokens to mint is within the allowed minting limits and the total supply has not been exceeded.
     * @param numberOfTokens The number of tokens to mint.
     * @param recipient The address that will receive the newly minted tokens.
     */
    function mint(uint256 numberOfTokens, address recipient) public payable {
        require(numberOfTokens > 0, "Must mint at least one token");
        require(numberOfTokens <= MAX_PER_MINT, "Cannot mint more than 3 tokens at a time");
        uint256 newTotalSupply = totalSupply + numberOfTokens;
        require(newTotalSupply <= maxSupply, "Exceeds maximum supply");
        require(
            balanceOf(recipient) + numberOfTokens <= MAX_TOKENS_PER_ADDRESS, "Recipient cannot own more than 6 tokens"
        );
        require(msg.value >= tokenPrice * numberOfTokens, "Ether value sent is not correct");

        for (uint256 i = 0; i < numberOfTokens; i++) {
            uint256 tokenId = totalSupply + i + 1;
            _safeMint(recipient, tokenId);
        }
        totalSupply = newTotalSupply;
    }

    /**
     * @notice Withdraws Ether from the contract to a recipient.
     * @dev Only the owner can withdraw funds from the contract.
     * @param amount The amount of Ether to withdraw.
     * @param recipient The address that will receive the Ether.
     */
    function withdraw(uint256 amount, address payable recipient) public onlyOwner {
        require(amount <= address(this).balance, "Insufficient balance");
        recipient.transfer(amount);
    }

    /**
     * @notice Returns the base URI for token metadata.
     * @dev Overrides the default `_baseURI()` method from the ERC721 standard.
     * @return The base URI for metadata.
     */
    function _baseURI() internal view override returns (string memory) {
        return baseTokenURI;
    }

    /**
     * @notice Allows the owner to set a new base URI for token metadata.
     * @dev This function can be used if the metadata storage location changes.
     * @param baseURI The new base URI for the token metadata.
     */
    function setBaseTokenURI(string memory baseURI) public onlyOwner {
        baseTokenURI = baseURI;
    }

    /**
     * @notice Allows the owner to update the maximum supply of tokens.
     * @dev This function should only be used in cases where the maximum token supply needs to be updated after deployment.
     *      It should be used carefully, as changing the maximum supply can affect the minting logic.
     * @param newValue The new maximum supply of tokens.
     */
    function setMaxSupply(uint256 newValue) public onlyOwner {
        require(newValue >= totalSupply, "New max supply must be greater than or equal to totalSupply");
        maxSupply = newValue;
    }
}
