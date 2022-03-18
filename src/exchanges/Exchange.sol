// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.10;

import {IExchange} from "../interfaces/IExchange.sol";

abstract contract Exchange is IExchange {

    //--------------------------------------------------------------------------
    // Storage

    /// @notice The Ample token address.
    address public immutable ample;

    /// @notice The address of the token to sell.
    address public immutable sellToken;

    //--------------------------------------------------------------------------
    // Constructor

    constructor(
        address ample_,
        address sellToken_
    ) {
        ample = ample_;
        sellToken = sellToken_;
    }

    //--------------------------------------------------------------------------
    // Abstract Functions

    /// @inheritdoc IExchange
    function sell(uint amount) external virtual;

}
