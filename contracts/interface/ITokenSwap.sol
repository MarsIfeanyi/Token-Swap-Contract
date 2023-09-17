// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

/**
 * @title Interface for interacting with the TokenSwap
 * @author Marcellus Ifeanyi
 * @notice This interface exposes the functionalities that allows you to interact with the TokenSwap Contract
 */
interface ITokenSwap {
    function addLiquidity(
        uint256 _amountTokenA,
        uint256 _amountTokenB
    ) external;

    function removeLiquidity(
        uint256 _amountTokenA,
        uint256 _amountTokenB
    ) external;

    function swapToken(
        address tokenAddress,
        uint256 _tokenAmount
    ) external returns (uint256);

    function getReserveA() external view returns (uint256);

    function getReserveB() external view returns (uint256);

    function getLiquidityProvided(
        address user
    ) external view returns (uint256, uint256);

    function getReserveA_and_ReserveB()
        external
        view
        returns (uint256, uint256);

    function getCPMM() external view returns (uint256);
}
