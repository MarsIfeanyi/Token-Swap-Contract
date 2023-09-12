// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

interface ITokenAB {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function mintToken(address to, uint256 amount) external;

    function burnToken(address to, uint256 amount) external;
}
