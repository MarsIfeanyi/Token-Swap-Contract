// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TokenBContract is ERC20 {
    address owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not Owner");
        _;
    }

    constructor() ERC20("TokenAContract", "TAC") {
        owner = msg.sender;

        _mint(msg.sender, 10000e18);
    }

    function mintToken(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    function burnToken(address to, uint256 amount) external onlyOwner {
        _burn(to, amount);
    }
}
