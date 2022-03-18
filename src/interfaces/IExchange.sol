// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

/**
 * @title The Exchange Interface
 *
 * @dev An Exchange implementation can be used to sell tokens for Amples.
 *
 * @author merkleplant
 */
interface IExchange {

    /// @notice Sells an amount of tokens for Amples.
    /// @param amount The amount of tokens to sell.
    function sell(uint amount) external;

}
