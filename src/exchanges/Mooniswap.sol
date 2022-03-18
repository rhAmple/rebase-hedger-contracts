// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.10;

import {ERC20} from "solmate/tokens/ERC20.sol";
import {SafeTransferLib} from "solmate/utils/SafeTransferLib.sol";

import {Exchange} from "./Exchange.sol";

interface IPool {
    // Copied from https://github.com/1inch/mooniswap/blob/master/contracts/Mooniswap.sol#L136.
    // Note that src and dst of type IERC20 was changed to address.
    function getReturn(
        address src,
        address dst,
        uint256 amount
    ) external view returns(uint256);

    // Copied from https://github.com/1inch/mooniswap#swap.
    function swap(
        address src,
        address dst,
        uint256 amount,
        uint256 minReturn,
        address referral
    ) external payable returns(uint256 result);
}

/**
 * @title The MainnetMooniswap Exchange
 *
 * @dev The Mooniswap exchange can be used by rebase hedgers to sell their
 *      receipt tokens for Ample.
 *
 * @author merkleplant
 */
contract MainnetMooniswap is Exchange {
    using SafeTransferLib for ERC20;

    //--------------------------------------------------------------------------
    // Storage

    /// @notice The Mooniswap pool address used.
    address public immutable pool;

    //--------------------------------------------------------------------------
    // Constructor

    constructor(
        address ample_,
        address sellToken_,
        address pool_
    ) Exchange(ample_, sellToken_) {
        pool = pool_;
    }

    //--------------------------------------------------------------------------
    // Overriden Exchange Functions

    /// @inheritdoc Exchange
    function sell(uint amount) external override(Exchange) {
        // Fetch sellTokens from msg.sender.
        ERC20(sellToken).safeTransferFrom(msg.sender, address(this), amount);

        // Sell sellTokens for Amples.
        IPool(pool).swap(
            sellToken,
            ample,
            amount,
            // Note to calculate expected return.
            IPool(pool).getReturn(sellToken, ample, amount),
            address(0)
        );

        // Send whole Ample balance to msg.sender.
        ERC20(ample).safeTransfer(
            msg.sender,
            ERC20(ample).balanceOf(address(this))
        );
    }

}
