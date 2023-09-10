// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TokenSwap {
    struct LiquidityProvider {
        uint256 amountTokenA;
        uint256 amountTokenB;
    }

    address tokenAContractAddress;
    address tokenBContractAddress;

    uint256 reserveA;
    uint256 reserveB;

    address[] path = [tokenAContractAddress, tokenBContractAddress];

    // exchange rate for each swap, (X+x) * (Y+y) = K

    // swap for X:  x = X-(K /(Y + y))

    // swap for Y: y = Y-(K /(X + x))

    mapping(address => LiquidityProvider) addressToLiquidityProvider;

    function addLiquidity(
        uint256 _amountTokenA,
        uint256 _amountTokenB
    ) external {
        require(_amountTokenA != (0), "Zero Amount");
        require(_amountTokenB != (0), "Zero Amount");

        IERC20(tokenAContractAddress).transferFrom(
            msg.sender,
            address(this),
            _amountTokenA
        );
        IERC20(tokenBContractAddress).transferFrom(
            msg.sender,
            address(this),
            _amountTokenB
        );

        reserveA += _amountTokenA;
        reserveB += _amountTokenB;

        LiquidityProvider
            storage liquidityProvider = addressToLiquidityProvider[msg.sender];

        liquidityProvider.amountTokenA += _amountTokenA;
        liquidityProvider.amountTokenB += _amountTokenB;
    }

    function swapTokenAtoTokenB(uint _swapAmount) external {
        require(_swapAmount != 0, "Zero Amount");
        IERC20(tokenAContractAddress).transferFrom(
            msg.sender,
            address(this),
            _swapAmount
        );
        uint256 reserveA_balance = getReserveA();
        reserveA_balance += _swapAmount;

        uint256 reserveB_balance = getReserveB();

        // swap for A:  a = A-(K /(B+ b))
        uint256 exchangeRate = (reserveB_balance * _swapAmount) /
            (reserveA_balance * _swapAmount);
        IERC20(tokenBContractAddress).transfer(msg.sender, exchangeRate);
    }

    function swapTokenBtoTokenA(uint _swapAmount) external {
        require(_swapAmount != 0, "Zero Amount");
        IERC20(tokenBContractAddress).transferFrom(
            msg.sender,
            address(this),
            _swapAmount
        );
        uint256 reserveB_balance = getReserveA();
        reserveB_balance += _swapAmount;

        uint256 reserveA_balance = getReserveB();

        // swap for B:  b = B-(K /(A+ a))
        uint256 exchangeRate = (reserveA_balance * _swapAmount) /
            (reserveB_balance * _swapAmount);
        IERC20(tokenBContractAddress).transfer(msg.sender, exchangeRate);
    }

    function removeLiquidity(
        uint256 _amountTokenA,
        uint256 _amountTokenB
    ) external {
        require(_amountTokenA != 0, "Zero Amount");
        require(_amountTokenB != 0, "Zero Amount");

        reserveA -= _amountTokenA;
        reserveB -= _amountTokenB;

        LiquidityProvider
            storage liquidityProvider = addressToLiquidityProvider[msg.sender];

        liquidityProvider.amountTokenA -= _amountTokenA;
        liquidityProvider.amountTokenB -= _amountTokenB;
    }

    function getReserveA() public view returns (uint256) {
        return reserveA;
    }

    function getReserveB() public view returns (uint256) {
        return reserveB;
    }

    function getLiquidityProvider(
        address user
    ) external view returns (uint256, uint256) {
        LiquidityProvider
            storage liquidityProvider = addressToLiquidityProvider[user];

        return (liquidityProvider.amountTokenA, liquidityProvider.amountTokenB);
    }
}
