// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./BaseHook.sol";
import "../interfaces/IVault.sol";
import "../interfaces/IERC20Extended.sol";

/**
 * @title ArbitrageHook
 * @notice Example Hook implementation that performs arbitrage swaps using the Vault
 * @dev This contract demonstrates how to use the vault swap functionality
 * for arbitrage opportunities across different pools
 */
contract ArbitrageHook is BaseHook {
    /**
     * @notice Emitted when an arbitrage opportunity is executed
     * @param poolA First pool in the arbitrage path
     * @param poolB Second pool in the arbitrage path
     * @param tokenA First token
     * @param tokenB Intermediate token
     * @param tokenC Final token
     * @param profit The profit from the arbitrage (in tokenC)
     */
    event ArbitrageExecuted(
        address indexed poolA,
        address indexed poolB,
        address tokenA,
        address tokenB,
        address tokenC,
        uint256 profit
    );

    /**
     * @notice Constructor
     * @param vault_ The Balancer V3 Vault address
     */
    constructor(address vault_) BaseHook(vault_) {}

    /**
     * @notice Executes a simple swap through the Vault
     * @dev This demonstrates the basic usage pattern for vault swaps in hooks
     *
     * @param pool The pool to swap through
     * @param tokenIn The input token
     * @param tokenOut The output token
     * @param amountIn The amount of tokenIn to swap
     * @param minAmountOut The minimum amount of tokenOut expected
     * @return amountOut The actual amount of tokenOut received
     */
    function executeSimpleSwap(
        address pool,
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 minAmountOut
    ) external returns (uint256 amountOut) {
        // Perform the vault swap using the base hook functionality
        (, , amountOut) = _performVaultSwap(
            IVault.SwapKind.EXACT_IN,
            pool,
            tokenIn,
            tokenOut,
            amountIn,
            minAmountOut,
            ""
        );

        // Send the output tokens to the caller
        IVault(_vault).sendTo(tokenOut, msg.sender, amountOut);

        return amountOut;
    }

    /**
     * @notice Executes a two-leg arbitrage swap: A -> B -> C
     * @dev This demonstrates a more complex usage pattern with multiple swaps
     *
     * @param poolA First pool (A -> B)
     * @param poolB Second pool (B -> C)
     * @param tokenA Starting token
     * @param tokenB Intermediate token
     * @param tokenC Ending token
     * @param amountA Amount of tokenA to start with
     * @param minAmountB Minimum amount of tokenB from first swap
     * @param minAmountC Minimum amount of tokenC from second swap
     * @return amountC The final amount of tokenC received
     */
    function executeTwoLegArbitrage(
        address poolA,
        address poolB,
        address tokenA,
        address tokenB,
        address tokenC,
        uint256 amountA,
        uint256 minAmountB,
        uint256 minAmountC
    ) external returns (uint256 amountC) {
        // First swap: A -> B
        (, , uint256 amountB) = _performVaultSwap(
            IVault.SwapKind.EXACT_IN,
            poolA,
            tokenA,
            tokenB,
            amountA,
            minAmountB,
            ""
        );

        // Second swap: B -> C
        (, , amountC) = _performVaultSwap(
            IVault.SwapKind.EXACT_IN,
            poolB,
            tokenB,
            tokenC,
            amountB,
            minAmountC,
            ""
        );

        // Calculate profit (if tokenA == tokenC)
        uint256 profit = 0;
        if (tokenA == tokenC && amountC > amountA) {
            profit = amountC - amountA;
        }

        emit ArbitrageExecuted(poolA, poolB, tokenA, tokenB, tokenC, profit);

        // Send the output tokens to the caller
        IVault(_vault).sendTo(tokenC, msg.sender, amountC);

        return amountC;
    }

    /**
     * @notice Executes a three-leg arbitrage swap: A -> B -> C -> A
     * @dev This demonstrates circular arbitrage across three pools
     *
     * @param poolA First pool (A -> B)
     * @param poolB Second pool (B -> C)
     * @param poolC Third pool (C -> A)
     * @param tokenA Starting and ending token
     * @param tokenB First intermediate token
     * @param tokenC Second intermediate token
     * @param amountA Amount of tokenA to start with
     * @param minAmountB Minimum amount of tokenB from first swap
     * @param minAmountC Minimum amount of tokenC from second swap
     * @param minProfitA Minimum profit in tokenA
     * @return finalAmountA The final amount of tokenA received
     * @return profit The profit in tokenA
     */
    function executeCircularArbitrage(
        address poolA,
        address poolB,
        address poolC,
        address tokenA,
        address tokenB,
        address tokenC,
        uint256 amountA,
        uint256 minAmountB,
        uint256 minAmountC,
        uint256 minProfitA
    ) external returns (uint256 finalAmountA, uint256 profit) {
        // First swap: A -> B
        (, , uint256 amountB) = _performVaultSwap(
            IVault.SwapKind.EXACT_IN,
            poolA,
            tokenA,
            tokenB,
            amountA,
            minAmountB,
            ""
        );

        // Second swap: B -> C
        (, , uint256 amountC) = _performVaultSwap(
            IVault.SwapKind.EXACT_IN,
            poolB,
            tokenB,
            tokenC,
            amountB,
            minAmountC,
            ""
        );

        // Third swap: C -> A
        (, , finalAmountA) = _performVaultSwap(
            IVault.SwapKind.EXACT_IN,
            poolC,
            tokenC,
            tokenA,
            amountC,
            amountA + minProfitA,
            ""
        );

        // Calculate profit
        require(finalAmountA > amountA, "ArbitrageHook: No profit");
        profit = finalAmountA - amountA;
        require(profit >= minProfitA, "ArbitrageHook: Insufficient profit");

        emit ArbitrageExecuted(poolA, poolB, tokenA, tokenB, tokenC, profit);

        // Send the output tokens to the caller
        IVault(_vault).sendTo(tokenA, msg.sender, finalAmountA);

        return (finalAmountA, profit);
    }
}
