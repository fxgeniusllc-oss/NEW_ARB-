// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title IVault
 * @notice Interface for Balancer V3 Vault
 * @dev This interface defines the core functions for interacting with the Vault
 */
interface IVault {
    /**
     * @notice Swap parameters structure
     * @param kind The type of swap (EXACT_IN or EXACT_OUT)
     * @param pool The pool address to swap through
     * @param tokenIn The token being sent to the pool
     * @param tokenOut The token being received from the pool
     * @param amountGivenRaw The amount being swapped (raw, without decimals adjustment)
     * @param limitRaw The minimum/maximum amount expected (raw, without decimals adjustment)
     * @param userData Additional data to pass to the pool
     */
    struct VaultSwapParams {
        SwapKind kind;
        address pool;
        address tokenIn;
        address tokenOut;
        uint256 amountGivenRaw;
        uint256 limitRaw;
        bytes userData;
    }

    /**
     * @notice Enum representing swap type
     * @param EXACT_IN Swap with exact input amount
     * @param EXACT_OUT Swap with exact output amount
     */
    enum SwapKind {
        EXACT_IN,
        EXACT_OUT
    }

    /**
     * @notice Performs a swap through the Vault
     * @param params The swap parameters
     * @return amountCalculated The calculated swap amount
     * @return amountIn The actual input amount
     * @return amountOut The actual output amount
     */
    function swap(VaultSwapParams calldata params)
        external
        returns (
            uint256 amountCalculated,
            uint256 amountIn,
            uint256 amountOut
        );

    /**
     * @notice Settles tokens sent to the Vault
     * @dev Updates the Vault's transient accounting with the correct balances
     * @param token The token address to settle
     * @param amount The amount to settle
     */
    function settle(address token, uint256 amount) external;

    /**
     * @notice Sends tokens from the Vault to a recipient
     * @param token The token address to send
     * @param to The recipient address
     * @param amount The amount to send
     */
    function sendTo(address token, address to, uint256 amount) external;
}
