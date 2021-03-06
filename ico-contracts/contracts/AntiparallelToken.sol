// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IAntiparallel.sol";

contract AntiparallelToken is ERC20, Ownable {
    // Price of one Antiparallel token
    uint256 public constant tokenPrice = 0.001 ether;
    // Each NFT gives user 10 tokens
    // ERC20 tokens have the smallest denomination of 10^(-18)
    // Having a balance of (1) is actually equal to (10 ^ -18) tokens
    // Owning 1 full token is equivalent to owning (10^18) tokens
    uint256 public constant tokensPerNFT = 10 * 10**18;
    // the max total supply is 10000
    uint256 public constant maxTotalSupply = 10000 * 10**18;
    // NFT contract instance
    IAntiparallel AntiparallelNFT;
    // Mapping to keep track of which tokenIds have been claimed
    mapping(uint256 => bool) public tokenIdsClaimed;

    constructor(address _antiparallelContract) ERC20("Antiparallel Token", "AP") {
        AntiparallelNFT = IAntiparallel(_antiparallelContract);
    }

    /**
    * @dev Mints `amount` number of tokens
    * Requirements:
    * - `msg.value` should be equal or greater than the tokenPrice * amount
    */
    function mint(uint256 amount) public payable {
        // the value of ether that should be equal or greater than tokenPrice * amount;
        uint256 _requiredAmount = tokenPrice * amount;
        require(msg.value >= _requiredAmount, "Ether sent is incorrect");
        // total tokens + amount <= 10000, otherwise revert the transaction
        uint256 amountWithDecimals = amount * 10**18;
        require(
            (totalSupply() + amountWithDecimals) <= maxTotalSupply,
            "Exceeds the max total supply available."
        );
        // call the internal function from Openzeppelin's ERC20 contract
        _mint(msg.sender, amountWithDecimals);
    }

    /**
    * @dev Mints tokens based on the number of NFT's held by the sender
    * Requirements:
    * balance of Antiparallel NFT's owned by the sender should be greater than 0
    * Tokens should have not been claimed for all the NFTs owned by the sender
    */
    function claim() public {
        address sender = msg.sender;
        // Get the number of NFT's held by a given sender address
        uint256 balance = AntiparallelNFT.balanceOf(sender);
        // If the balance is zero, revert the transaction
        require(balance > 0, "You dont own any Antiparallel NFT's");
        // amount keeps track of number of unclaimed NFT tokenIds
        uint256 amount = 0;
        // loop over the balance and get the NFT token ID owned by `sender` at a given `index` of its token list.
        for (uint256 i = 0; i < balance; i++) {
            uint256 tokenId = AntiparallelNFT.tokenOfOwnerByIndex(sender, i);
            // if the tokenId has not been claimed, increase the amount
            if (!tokenIdsClaimed[tokenId]) {
                amount += 1;
                tokenIdsClaimed[tokenId] = true;
            }
        }
        // If all the token Ids have been claimed, revert the transaction;
        require(amount > 0, "You have already claimed all the tokens");
        // call the internal function from Openzeppelin's ERC20 contract
        // Mint (amount * 10) tokens for each NFT
        _mint(msg.sender, amount * tokensPerNFT);
    }

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}
}
