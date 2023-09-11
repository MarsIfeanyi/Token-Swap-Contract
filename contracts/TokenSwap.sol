// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {TokenAContract} from "./TokenAContract.sol";
import {TokenBContract} from "./TokenBContract.sol";

contract TokenSwap {
    error WrongTokenAddressForSwap(address tokenAddress);
    struct LiquidityProvider {
        uint256 amountTokenA;
        uint256 amountTokenB;
    }

    address tokenA_Address;
    address tokenB_Address;

    uint256 reserveA; // holds the TotalLiquidity for TokenA
    uint256 reserveB;

    mapping(address => LiquidityProvider) addressToLiquidityProvider;

    constructor(address _tokenA_Address, address _tokenB_Address) {
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
        uint256 _amountTokenA,
        uint256 _amountTokenB,
        address user
    );
    event TokenB_For_TokenA_Swapped(
        uint256 _amountTokenB,
        uint256 _amountTokenA,
        address user
    );

    function addLiquidity(
        uint256 _amountTokenA,
        uint256 _amountTokenB
    ) external {
        require(_amountTokenA != (0), "Zero Token Amount");
        require(_amountTokenB != (0), "Zero Token Amount");

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

        reserveA += _amountTokenA;
        reserveB += _amountTokenB;

        LiquidityProvider
            storage liquidityProvider = addressToLiquidityProvider[msg.sender];

        liquidityProvider.amountTokenA += _amountTokenA;
        liquidityProvider.amountTokenB += _amountTokenB;

        // Mint certificate(receipt) tokens upon successful deposits
        TokenAContract(tokenA_Address).mintToken(msg.sender, _amountTokenA);
        TokenBContract(tokenB_Address).mintToken(msg.sender, _amountTokenB);

        emit LiquidityAdded(_amountTokenA, _amountTokenB, msg.sender);
    }

    function removeLiquidity(
        uint256 _amountTokenA,
        uint256 _amountTokenB
    ) external {
        LiquidityProvider
            storage liquidityProvider = addressToLiquidityProvider[msg.sender];

        // checks
        require(
            liquidityProvider.amountTokenA >= _amountTokenA,
            "Insufficient Token Amount"
        );
        require(_amountTokenA != 0, "Zero Token Amount");

        require(
            liquidityProvider.amountTokenB >= _amountTokenB,
            "Insufficient Token Amount"
        );
        require(_amountTokenB != 0, "Zero Token Amount");

        // decrease the amounts of the LiquidityProvider
        liquidityProvider.amountTokenA -= _amountTokenA;
        liquidityProvider.amountTokenB -= _amountTokenB;

        reserveA -= _amountTokenA;
        reserveB -= _amountTokenB;

        // burn the certificate(receipt) tokens
        TokenAContract(tokenA_Address).burnToken(msg.sender, _amountTokenA);
        TokenBContract(tokenB_Address).burnToken(msg.sender, _amountTokenB);

        // Transfer the token back to the owner
        bool tokenA_Success = IERC20(tokenA_Address).transfer(
            msg.sender,
            _amountTokenA
        );
        require(tokenA_Success, "TokenA_Liquidity: Transfer Failed");
        bool tokenB_Success = IERC20(tokenB_Address).transfer(
            msg.sender,
            _amountTokenB
        );
        require(tokenB_Success, "TokenB_Liquidity: Transfer Failed");

        emit LiquidityRemoved(_amountTokenA, _amountTokenB, msg.sender);
    }

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

    // swap TokenA for TokenB:  b = B-(K /(A + a))
    function calculateRateOf_TokenA_For_TokenB(
        uint256 _amountTokenA
    ) internal view returns (uint256) {
        uint256 K = reserveA * reserveB;
        uint256 sumTokenA = (reserveA + _amountTokenA);

        uint expectedAmountOfTokenB = reserveB - (K / sumTokenA);

        return expectedAmountOfTokenB;
    }

    // swap TokenB for TokenA: a = A - (K /(B + b))
    function calculateRateOf_TokenB_For_TokenA(
        uint256 _amountTokenB
    ) internal view returns (uint256) {
        uint256 K = reserveA * reserveB;
        uint256 sumTokenB = (reserveB + _amountTokenB);

        uint expectedAmountOfTokenA = reserveA - (K / sumTokenB);

        return expectedAmountOfTokenA;
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
