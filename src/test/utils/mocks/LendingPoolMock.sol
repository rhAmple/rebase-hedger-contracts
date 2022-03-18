// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.10;

import {ERC20} from "solmate/tokens/ERC20.sol";
import {SafeTransferLib} from "solmate/utils/SafeTransferLib.sol";

import {ERC20Mock} from "./ERC20Mock.sol";

interface ILendingPool {
    function deposit(
        address asset,
        uint256 amount,
        address onBehalfOf,
        uint16 referralCode
    ) external;
    function withdraw(
        address asset,
        uint256 amount,
        address to
    ) external returns (uint256);
}

contract LendingPoolMock is ILendingPool {
    using SafeTransferLib for ERC20;

    ERC20Mock private _receiptToken;

    bool private _shouldWithdrawFail;
    uint private _amountOut;

    constructor(address receiptToken) {
        _receiptToken = ERC20Mock(receiptToken);
    }

    function setShouldWithdrawFail(bool to) external {
        _shouldWithdrawFail = to;
    }

    function setAmountOut(uint to) external {
        _amountOut = to;
    }

    //--------------------------------------------------------------------------
    // ILendingPool Functions

    function deposit(
        address asset,
        uint amount,
        address onBehalfOf,
        uint16 referralCode
    ) external {
        require(referralCode == uint16(0));

        ERC20(asset).safeTransferFrom(msg.sender, address(this), amount);

        _receiptToken.mint(onBehalfOf, amount);
    }

    function withdraw(address asset, uint amount, address to)
        external
        returns (uint)
    {
        if (_shouldWithdrawFail) {
            revert("LendingPool: Withdrawal failed");
        }

        // Depositor receives a different amount of tokens than deposited.
        uint balance = ERC20(asset).balanceOf(address(this));
        if (balance < _amountOut) {
            ERC20Mock(asset).mint(address(this), _amountOut - balance);
        }

        ERC20(asset).safeTransfer(to, _amountOut);

        // Independent of the amount the user receives, all receipt tokens are
        // burned.
        _receiptToken.burn(msg.sender, amount);

        return amount;
    }

}
