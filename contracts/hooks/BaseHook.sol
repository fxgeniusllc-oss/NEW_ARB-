// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../interfaces/IVault.sol";
import "../interfaces/IERC20Extended.sol";

/**
 * @title BaseHook
 * @notice Abstract contract providing base functionality for Balancer V3 Hooks
 * @dev Hooks are separate smart contracts that interact directly with the Vault
 * Unlike Externally Owned Accounts (EOAs) which use the Router with Permit2,
 * Hooks cannot sign permissions and must interact directly with the Vault.
 */
abstract contract BaseHook {
    /// @notice The Balancer V3 Vault address
    address internal immutable _vault;

    /**
     * @notice Emitted when a swap is executed through the hook
     * @param pool The pool used for the swap
     * @param tokenIn The input token
     * @param tokenOut The output token
     * @param amountIn The input amount
     * @param amountOut The output amount
     */
    event SwapExecuted(
        address indexed pool,
        address indexed tokenIn,
        address indexed tokenOut,
        uint256 amountIn,
        uint256 amountOut
    );

    /**
     * @notice Constructor to set the Vault address
     * @param vault_ The Balancer V3 Vault address
     */
    constructor(address vault_) {
        require(vault_ != address(0), "BaseHook: Invalid vault address");
        _vault = vault_;
    }

    /**
     * @notice Performs a swap through the Vault
     * @dev This function follows the pattern described in the Balancer V3 documentation:
     * 1. Send tokens to the Vault
     * 2. Settle the tokens with the Vault (updates transient accounting)
     * 3. Perform the swap
     *
     * @param kind The type of swap (EXACT_IN or EXACT_OUT)
     * @param pool The pool address to swap through
     * @param tokenIn The token being sent to the pool
     * @param tokenOut The token being received from the pool
     * @param amount The amount being swapped (raw, without decimals adjustment)
     * @param limit The minimum/maximum amount expected (raw, without decimals adjustment)
     * @param userData Additional data to pass to the pool
     * @return amountCalculated The calculated swap amount
     * @return amountIn The actual input amount
     * @return amountOut The actual output amount
     */
    function _performVaultSwap(
        IVault.SwapKind kind,
        address pool,
        address tokenIn,
        address tokenOut,
        uint256 amount,
        uint256 limit,
        bytes memory userData
    )
        internal
        returns (
            uint256 amountCalculated,
            uint256 amountIn,
            uint256 amountOut
        )
    {
        // Step 1: Send the tokens you are swapping to the Vault
        IERC20Extended(tokenIn).transfer(_vault, amount);

        // Step 2: Inform the Vault you have sent it tokens
        // This will update the Vault's transient accounting with the correct balances
        IVault(_vault).settle(tokenIn, amount);

        // Step 3: Perform the swap
        (amountCalculated, amountIn, amountOut) = IVault(_vault).swap(
            IVault.VaultSwapParams({
                kind: kind,
                pool: pool,
                tokenIn: tokenIn,
                tokenOut: tokenOut,
                amountGivenRaw: amount,
                limitRaw: limit,
                userData: userData
            })
        );

        emit SwapExecuted(pool, tokenIn, tokenOut, amountIn, amountOut);

        return (amountCalculated, amountIn, amountOut);
    }

    /**
     * @notice Gets the Vault address
     * @return The Balancer V3 Vault address
     */
    function getVault() external view returns (address) {
        return _vault;
    }
}
