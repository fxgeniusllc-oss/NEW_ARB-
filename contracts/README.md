# Balancer V3 Vault Swap for Hooks

This directory contains the implementation of Balancer V3 Vault swap functionality for Hooks, following the official Balancer V3 documentation patterns.

## Overview

The Balancer Router is typically the interface Externally Owned Accounts (EOAs) use to interact with the V3 Vault. While the Router uses Permit2 for token permissions, Hooks—being separate smart contracts—cannot sign these permissions. Instead, Hooks interact directly with the Vault.

## Architecture

### Interfaces

#### `IVault.sol`
The core Vault interface defining:
- `VaultSwapParams` struct for swap parameters
- `SwapKind` enum (EXACT_IN, EXACT_OUT)
- `swap()` function for executing swaps
- `settle()` function for updating transient accounting
- `sendTo()` function for sending tokens from the Vault

#### `IERC20Extended.sol`
Extended ERC20 interface with additional utility functions like `decimals()`, `name()`, and `symbol()`.

### Base Contracts

#### `BaseHook.sol`
Abstract base contract providing core vault swap functionality:
- Stores immutable Vault address
- Implements `_performVaultSwap()` following the three-step pattern:
  1. **Send tokens to Vault**: `token.transfer(_vault, amount)`
  2. **Settle with Vault**: `_vault.settle(token, amount)` - Updates transient accounting
  3. **Perform swap**: `_vault.swap(VaultSwapParams(...))` - Executes the swap
- Emits `SwapExecuted` events for monitoring

### Example Implementations

#### `ArbitrageHook.sol`
Demonstrates practical usage of vault swaps with three example functions:

1. **Simple Swap** (`executeSimpleSwap`):
   - Single swap: Token A → Token B
   - Basic usage pattern demonstration

2. **Two-Leg Arbitrage** (`executeTwoLegArbitrage`):
   - Double swap: Token A → Token B → Token C
   - Shows sequential swap execution

3. **Circular Arbitrage** (`executeCircularArbitrage`):
   - Triple swap: Token A → Token B → Token C → Token A
   - Demonstrates profit calculation and validation
   - Ensures minimum profit requirements

## Usage Pattern

The standard pattern for making a swap in a Hook is:

```solidity
// Step 1: Send the tokens to the Vault
IERC20(tokenIn).transfer(_vault, amount);

// Step 2: Inform the Vault you have sent it tokens
// This updates the Vault's transient accounting
_vault.settle(tokenIn, amount);

// Step 3: Perform the swap
(amountCalculated, amountIn, amountOut) = _vault.swap(
    VaultSwapParams({
        kind: SwapKind.EXACT_IN,
        pool: pool,
        tokenIn: tokenIn,
        tokenOut: tokenOut,
        amountGivenRaw: amount,
        limitRaw: minAmountOut,
        userData: ""
    })
);
```

## Key Concepts

### Transient Accounting
The `settle()` function updates the Vault's internal transient accounting system. This is critical for the Vault to properly track token balances during complex operations.

### Direct Vault Interaction
Unlike EOAs that use the Router and Permit2:
- Hooks cannot sign Permit2 permissions (they're smart contracts, not wallets)
- Hooks must transfer tokens directly to the Vault
- Hooks must call `settle()` to update accounting
- Hooks interact directly with the Vault contract

### Swap Kinds
- **EXACT_IN**: Specify exact input amount, receive calculated output
- **EXACT_OUT**: Specify exact output amount, provide calculated input

## Integration with APEX Arbitrage System

This vault swap functionality integrates with the APEX system's:
- **Python AI Engine**: Opportunity detection and profit calculation
- **TypeScript Core**: Swap orchestration and monitoring
- **Rust Executor**: High-speed transaction execution

The hooks can be called from the Rust executor layer for maximum performance in MEV arbitrage scenarios.

## Security Considerations

1. **Token Approvals**: Ensure the Hook has sufficient token approvals before calling swap functions
2. **Slippage Protection**: Always use the `limitRaw` parameter to protect against slippage
3. **Reentrancy**: The Vault implements reentrancy protection, but custom hooks should also consider this
4. **Access Control**: Implement appropriate access controls on swap functions to prevent unauthorized usage

## Gas Optimization

The vault swap pattern is gas-efficient because:
- Direct Vault interaction avoids Router overhead
- Transient accounting reduces storage operations
- Single transaction for multiple swaps in complex arbitrage

## Testing

To test the vault swap functionality:

1. Deploy a mock Vault contract implementing `IVault`
2. Deploy the hook contract with the Vault address
3. Fund the hook with tokens
4. Execute swaps and verify outputs
5. Test edge cases (insufficient balance, slippage, etc.)

## Future Enhancements

Potential improvements to consider:
- Flash loan integration for zero-capital arbitrage
- Multi-path routing for complex arbitrage
- MEV protection mechanisms
- Gas optimization for batch operations
- Emergency pause functionality

## References

- [Balancer V3 Documentation](https://docs.balancer.fi/)
- [Balancer V3 Vault](https://github.com/balancer/balancer-v3-monorepo)
- [Hook Development Guide](https://docs.balancer.fi/concepts/explore-available-balancer-pools/hooks.html)
