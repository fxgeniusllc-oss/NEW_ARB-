// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title IERC20Extended
 * @notice Extended ERC20 interface with additional utility functions
 */
interface IERC20Extended is IERC20 {
    /**
     * @notice Returns the number of decimals used by the token
     */
    function decimals() external view returns (uint8);

    /**
     * @notice Returns the name of the token
     */
    function name() external view returns (string memory);

    /**
     * @notice Returns the symbol of the token
     */
    function symbol() external view returns (string memory);
}
