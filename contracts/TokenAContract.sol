// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TokenAContract is ERC20 {
    address owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not Owner");
        _;
    }

    event ReceiptTokenMinted(address indexed to, uint256 indexed amount);
    event ReceiptTokenBurned(address indexed to, uint256 indexed amount);

    constructor() ERC20("TokenAContract", "TAC") {
        owner = msg.sender;

        _mint(msg.sender, 1_000_000e18);
    }

    /**
     * @param to: address of the receiver(msg.sender)
     * @param amount: amount to mint
     *
     * @dev mints the receipt token to a user upon successful deposits or addition of liquidity to the pool
     */
    function mintToken(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);

        emit ReceiptTokenMinted(to, amount);
    }

    /**
     * @param to: address of the receiver(msg.sender)
     * @param amount: amount to mint
     *
     * @dev burns the receipt token from the  user upon successful withdrawal or removal of liquidity from the pool
     */
    function burnToken(address to, uint256 amount) external onlyOwner {
        _burn(to, amount);

        emit ReceiptTokenBurned(to, amount);
    }
}
