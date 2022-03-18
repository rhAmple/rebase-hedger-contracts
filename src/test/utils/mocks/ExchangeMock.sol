// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.10;

import {ERC20} from "solmate/tokens/ERC20.sol";
import {SafeTransferLib} from "solmate/utils/SafeTransferLib.sol";

import {ERC20Mock} from "./ERC20Mock.sol";

import {Exchange} from "../../../exchanges/Exchange.sol";

contract ExchangeMock is Exchange {
    using SafeTransferLib for ERC20;

    uint private _amountOut;

    constructor(address ample_, address sellToken_)
        Exchange(ample_, sellToken_)
    {
        // NO-OP
    }

    function setAmountOut(uint to) external {
        _amountOut = to;
    }

    //--------------------------------------------------------------------------
    // Override Exchange Functions

    function sell(uint amount) external override(Exchange) {
        ERC20(sellToken).safeTransferFrom(msg.sender, address(this), amount);

        ERC20Mock(ample).mint(address(this), _amountOut);

        // User should receive _amountOut of Amples and lose amount of
        // sellTokens.
        ERC20(ample).safeTransfer(msg.sender, _amountOut);
    }

}
