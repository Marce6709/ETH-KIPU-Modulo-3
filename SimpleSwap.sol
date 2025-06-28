// SPDX-License-Identifier: MIT
pragma solidity >0.8.0;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {TokenFactory} from "./TokenFactory.sol";

interface IERC20Mintable is IERC20 {
    /// @notice Mints `amount` tokens to `to`.
    /// @param to Address receiving the minted tokens.
    /// @param amount Number of tokens to mint.
    function mint(address to, uint256 amount) external;
    /// @param amount Number of tokens to burn.
    /// @notice Burns `amount` tokens from caller.
    /// @return success True if burn succeeded.
    function burn(uint256 amount) external returns (bool success);
}

contract SimpleSwap is TokenFactory {

    
    uint256 private supplyLiquidity;
    uint256 private constant DECIMALS = 1e18;
    uint256 private constant MINIMUN_LIQUIDITY = 10000;

    event LiquidityAdded(address indexed provider, uint256 amountA, uint256 amountB);
    event LiquidityRemoved(address indexed provider, uint256 amountA, uint256 amountB);
    event Swap(address indexed sender, address indexed recipient, uint256 amountIn, uint256 amountOut);

    constructor() TokenFactory("LiquidityPair", "LP") {
        mint(address(this),MINIMUN_LIQUIDITY);
    }

    /// @notice Ensures function is called before `deadline`.
    /// @param deadline Unix timestamp after which the call is invalid.
    modifier ensure(uint256 deadline) {
        require(deadline >= block.timestamp, "ExpiredDeadline");
        _;
    }

   

    /// @notice Adds liquidity for `tokenA`/`tokenB` pair.
    /// @param tokenA First token address.
    /// @param tokenB Second token address.
    /// @param amountADesired Max amount of A to deposit.
    /// @param amountBDesired Max amount of B to deposit.
    /// @param amountAMin Min amount of A to accept.
    /// @param amountBMin Min amount of B to accept.
    /// @param to Recipient of LP tokens.
    /// @param deadline Last valid timestamp.
    /// @return amountA Actual A added.
    /// @return amountB Actual B added.
    /// @return liquidity LP tokens minted.
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external ensure(deadline)  returns (uint256 amountA, uint256 amountB, uint256 liquidity) {
       

        address pool = address(this);

        uint256 reserveA = IERC20(tokenA).balanceOf(pool);
        uint256 reserveB = IERC20(tokenB).balanceOf(pool);
        

        uint256 amountOutA = getAmountOut(amountBDesired, reserveB, reserveA);
        if (amountOutA <= amountADesired) {
            require(amountOutA >= amountAMin, "InsufficientA");
            amountA = amountOutA;
            amountB = amountBDesired;
        } else {
            uint256 amountOutB = getAmountOut(amountADesired, reserveA, reserveB);
            require(amountOutB >= amountBMin, "InsufficientB");
            amountA = amountADesired;
            amountB = amountOutB;
        }
        

        IERC20(tokenA).transferFrom(msg.sender, pool, amountA);
        IERC20(tokenB).transferFrom(msg.sender, pool, amountB);



        supplyLiquidity = totalSupply();
        uint256 liquidityA = (amountA * supplyLiquidity) / reserveA;
        uint256 liquidityB = (amountB * supplyLiquidity) / reserveB;
        liquidity = liquidityA < liquidityB ? liquidityA : liquidityB;

        mint(to, liquidity);
        emit LiquidityAdded(msg.sender, amountA, amountB);
    }

    /// @notice Burns `liquidity` LP tokens and returns underlying tokens.
    /// @param tokenA First token address.
    /// @param tokenB Second token address.
    /// @param liquidity Amount of LP tokens to burn.
    /// @param amountAMin Min A to receive.
    /// @param amountBMin Min B to receive.
    /// @param to Recipient of underlying.
    /// @param deadline Last valid timestamp.
    /// @return amountA A returned.
    /// @return amountB B returned.
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external ensure(deadline)  returns (uint256 amountA, uint256 amountB) {
        
        address pool = address(this);
        uint256 reserveA = IERC20(tokenA).balanceOf(pool);
        uint256 reserveB = IERC20(tokenB).balanceOf(pool);
        

        supplyLiquidity = totalSupply();
        amountA = (liquidity * reserveA) / supplyLiquidity;
        require(amountA >= amountAMin, "InsufficientA");
        amountB = (liquidity * reserveB) / supplyLiquidity;
        require(amountB >= amountBMin, "InsufficientB");

        burn(liquidity);
        (bool successA) = IERC20(tokenA).transfer(to, amountA);
        (bool successB) = IERC20(tokenB).transfer(to, amountB);
        require(successA, "TransferAfailed");
        require(successB, "TransferBfailed");

        emit LiquidityRemoved(msg.sender, amountA, amountB);
    }

    /// @notice Swap an exact `amountIn` of `path[0]` for as many `path[1]` as possible, enforcing `amountOutMin`.
    /// @param amountIn Input token amount.
    /// @param amountOutMin Minimum acceptable output.
    /// @param path [input, output] token addresses.
    /// @param to Recipient of output tokens.
    /// @param deadline Last valid timestamp.
    /// @return amounts Array of amountIn and amountOut.
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external ensure(deadline)  returns (uint[] memory amounts) {
        require(path.length == 2, "InvalidPath");
        address pool = address(this);

        uint256 reserveIn = IERC20(path[0]).balanceOf(pool);
        uint256 reserveOut = IERC20(path[1]).balanceOf(pool);
        uint256 amountOut = getAmountOut(amountIn, reserveIn, reserveOut);
        require(amountOut >= amountOutMin, "InsufficientOutput");

       IERC20(path[0]).transferFrom(msg.sender, pool, amountIn);
       IERC20(path[1]).transfer(to, amountOut);
        

        
        amounts[0] = amountIn;
        amounts[1] = amountOut;
        
        emit Swap(msg.sender, to, amountIn, amountOut);
    }

    /// @notice Returns raw price of `tokenA` to `tokenB` as reserveA/reserveB.
    /// @param tokenA Base token.
    /// @param tokenB Quote token.
    /// @return price tokenA/tokenB price.
    function getPrice(address tokenA, address tokenB) external view  returns (uint256 price) {
        uint256 reserveA = IERC20(tokenA).balanceOf(address(this));
        uint256 reserveB = IERC20(tokenB).balanceOf(address(this));
        require(reserveA > 0 && reserveB > 0, "MIERDA");
        return (reserveA * DECIMALS) / reserveB;
    }

    /// @notice Given `amountIn` and reserves, returns max `amountOut`.
    /// @param amountIn Input token amount.
    /// @param reserveIn Input reserve.
    /// @param reserveOut Output reserve.
    /// @return amountOut Calculated output amount.
    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) public pure returns (uint256 amountOut) {
        return amountOut = (amountIn * reserveOut) / reserveIn;
    }
}
