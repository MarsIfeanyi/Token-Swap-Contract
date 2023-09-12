// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {TokenAContract} from "./TokenAContract.sol";
import {TokenBContract} from "./TokenBContract.sol";

/**
 * @title TokenSwap Contract
 * @author Marcellus Ifeanyi
 * @notice This contract allows you to add Liquidity to the liquidity Pool, remove liquidty from the liquidity pool and Swap tokens in both directions, it uses the Constant Product Market Marker(CPMM) to calculate the rate swaps
 */

contract TokenSwap {
    error WrongTokenAddressForSwap(address tokenAddress);
    struct LiquidityProvider {
        uint256 amountTokenA;
        uint256 amountTokenB;
    }

    address tokenA_Address;
    address tokenB_Address;

    uint256 reserveA; // holds the TotalLiquidity supplied for TokenA
    uint256 reserveB; // holds the TotalLiquidity supplied for TokenB

    mapping(address => LiquidityProvider) addressToLiquidityProvider; // keeps track of the liquidity provided by a given address on the contract

    constructor(address _tokenA_Address, address _tokenB_Address) {
        // initializing the state variables
        tokenA_Address = _tokenA_Address;
        tokenB_Address = _tokenB_Address;
    }

    event LiquidityAdded(
        uint256 indexed amountOfTokenA,
        uint256 indexed amountOfTokenB,
        address indexed user
    );
    event LiquidityRemoved(
        uint256 indexed amountOfTokenA,
        uint256 indexed amountOfTokenB,
        address indexed user
    );

    event TokenA_For_TokenB_Swapped(
        uint256 indexed _amountTokenA,
        uint256 indexed _amountTokenB,
        address indexed user
    );
    event TokenB_For_TokenA_Swapped(
        uint256 indexed _amountTokenB,
        uint256 indexed _amountTokenA,
        address indexed user
    );

    /**
     * @param _amountTokenA: the amount of tokenA that a liquidity provider wants to `add` to the liquidity pool of A (reserveA)
     * @param _amountTokenB: the amount of tokenB that a liquidity provider wants to `add` to the liquidity pool of B (reserveB)
     *
     * @dev adds the liquity of the pair tokens that a liquidity provider brings to the pool for reserveA and reserveB respectively
     */
    function addLiquidity(
        uint256 _amountTokenA,
        uint256 _amountTokenB
    ) external {
        require(_amountTokenA > 0, "Zero Token Amount");
        require(_amountTokenB > 0, "Zero Token Amount");

        IERC20(tokenA_Address).transferFrom(
            msg.sender,
            address(this),
            _amountTokenA
        );
        IERC20(tokenB_Address).transferFrom(
            msg.sender,
            address(this),
            _amountTokenB
        );

        // Add the input Liquidity amounts to the liquidity pool of TokenA and TokenB
        reserveA += _amountTokenA;
        reserveB += _amountTokenB;

        LiquidityProvider
            storage liquidityProvider = addressToLiquidityProvider[msg.sender];

        // Updates and `adds` the input liquidity  amounts for the address that calls the addLiquidity()
        liquidityProvider.amountTokenA += _amountTokenA;
        liquidityProvider.amountTokenB += _amountTokenB;

        // After updating the Blockchain state, emit an event
        emit LiquidityAdded(_amountTokenA, _amountTokenB, msg.sender);
    }

    /**
     * @param _amountTokenA: the amount of tokenA that a liquidity provider wants to `remove` from the liquidity pool of A (reserveA)
     * @param _amountTokenB: the amount of tokenB that a liquidity provider wants to `remove` to the liquidity pool of B (reserveB)
     *
     * @dev removes the liquity of the pair tokens that a liquidity provider brings to the pool for reserveA and reserveB respectively
     */
    function removeLiquidity(
        uint256 _amountTokenA,
        uint256 _amountTokenB
    ) external {
        LiquidityProvider
            storage liquidityProvider = addressToLiquidityProvider[msg.sender];

        // checks that the amountTokenA in the liquidity pool that the provider owns is greater than or equal to the _amountTokenA liquidity he wants to remove
        require(
            liquidityProvider.amountTokenA >= _amountTokenA,
            "Insufficient Token Amount"
        );

        require(_amountTokenA > 0, "Zero Token Amount");

        require(
            liquidityProvider.amountTokenB >= _amountTokenB,
            "Insufficient Token Amount"
        );
        require(_amountTokenB > 0, "Zero Token Amount");

        // Updates and `subtracts` the input liquidity  amounts for the address that calls the removeLiquidity()
        liquidityProvider.amountTokenA -= _amountTokenA;
        liquidityProvider.amountTokenB -= _amountTokenB;

        reserveA -= _amountTokenA;
        reserveB -= _amountTokenB;

        // Transfers the tokens Amount back to the owner
        (bool tokenA_Success, ) = payable(tokenA_Address).call{
            value: _amountTokenA
        }("");
        require(tokenA_Success, "TokenA_Liquidity: Transfer Failed");

        (bool tokenB_Success, ) = payable(tokenB_Address).call{
            value: _amountTokenB
        }("");
        require(tokenB_Success, "TokenB_Liquidity: Transfer Failed");

        emit LiquidityRemoved(_amountTokenA, _amountTokenB, msg.sender);
    }

    /**
     * @param tokenAddress: the address the holds the token amount to be swapped.
     * @param _tokenAmount: the amount of token to be swapped
     *
     * @dev compares the token address and calls the the internal swap functions depending on the result of the comparisons and throws an error if there is no matching address
     */
    function swapToken(address tokenAddress, uint256 _tokenAmount) external {
        if (tokenAddress == tokenA_Address) {
            _swapTokenA_For_TokenB(_tokenAmount);
        } else if (tokenAddress == tokenB_Address) {
            _swapTokenB_For_TokenA(_tokenAmount);
        } else {
            revert WrongTokenAddressForSwap(tokenAddress);
        }
    }

    function _swapTokenA_For_TokenB(uint256 _amountTokenA) internal {
        require(
            IERC20(tokenA_Address).allowance(msg.sender, address(this)) >=
                _amountTokenA,
            "ERC20: Insufficient TokenA Allowance"
        );
        require(_amountTokenA > 0, "Zero TokenA Amount");

        IERC20(tokenA_Address).transferFrom(
            msg.sender,
            address(this),
            _amountTokenA
        );

        // The amount of TokenB, a user gets when he brings tokenA for a swap
        uint _amountTokenB = calculateRateOf_TokenA_For_TokenB(_amountTokenA);
        (bool success, ) = tokenB_Address.call{value: _amountTokenB}("");
        require(success, "TokenB Transfer Failed");

        emit TokenA_For_TokenB_Swapped(
            _amountTokenA,
            _amountTokenB,
            msg.sender
        );
    }

    function _swapTokenB_For_TokenA(uint256 _amountTokenB) internal {
        require(
            IERC20(tokenB_Address).allowance(msg.sender, address(this)) >=
                _amountTokenB,
            "ERC20: Insufficient TokenB Allowance"
        );
        require(_amountTokenB > 0, "Zero TokenB Allowance");

        IERC20(tokenB_Address).transferFrom(
            msg.sender,
            address(this),
            _amountTokenB
        );
        //  The amount of TokenA, a user gets when he brings tokenB for a swap
        uint256 _amountTokenA = calculateRateOf_TokenB_For_TokenA(
            _amountTokenB
        );

        (bool success, ) = tokenA_Address.call{value: _amountTokenA}("");
        require(success, "TokenB Transfer Failed");

        emit TokenB_For_TokenA_Swapped(
            _amountTokenB,
            _amountTokenA,
            msg.sender
        );
    }

    // Calculating the ExchangeRate Using the Constant Product Market Marker(CPMM), K = X * Y, where X = reserve of TokenA  and Y =  reserve of TokenB

    /**
     * @param _amountTokenA: The amount of tokenA a users brings for a swap to get tokenB
     * 
     * @dev uses the CPMM formula to calculate the amount of tokenB a user will get in return when he brings tokenA for a swap
     * 
     * swap TokenA for TokenB:
    (A+a) * (B-b) = K
     b = B-(K /(A + a))
     */
    function calculateRateOf_TokenA_For_TokenB(
        uint256 _amountTokenA
    ) internal view returns (uint256) {
        uint256 K = reserveA * reserveB;

        uint256 sumTokenA = (reserveA + _amountTokenA);

        uint expectedAmountOfTokenB = reserveB - (K / sumTokenA);

        return expectedAmountOfTokenB;
    }

    /**
     * @param _amountTokenB: The amount of tokenB a users brings for a swap to get tokenA
     * 
     * @dev uses the CPMM formula to calculate the amount of tokenA a user will get in return when he brings tokenB for a swap
     * 
     * swap TokenB for TokenA:
    (A-a) * (B+b) = K
     a = A - (K /(B + b))
     */

    function calculateRateOf_TokenB_For_TokenA(
        uint256 _amountTokenB
    ) internal view returns (uint256) {
        uint256 K = reserveA * reserveB;
        uint256 sumTokenB = (reserveB + _amountTokenB);

        uint expectedAmountOfTokenA = reserveA - (K / sumTokenB);

        return expectedAmountOfTokenA;
    }

    function getReserveA() external view returns (uint256) {
        return reserveA;
    }

    function getReserveB() external view returns (uint256) {
        return reserveB;
    }

    function getLiquidityProvided(
        address user
    ) external view returns (uint256, uint256) {
        LiquidityProvider
            storage liquidityProvider = addressToLiquidityProvider[user];

        return (liquidityProvider.amountTokenA, liquidityProvider.amountTokenB);
    }

    function getReserveA_and_ReserveB()
        external
        view
        returns (uint256, uint256)
    {
        return (reserveA, reserveB);
    }

    function getCPMM() external view returns (uint256) {
        uint K = reserveA * reserveB;
        return K;
    }
}
