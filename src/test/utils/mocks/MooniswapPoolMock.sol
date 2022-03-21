// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.10;

import {ERC20} from "solmate/tokens/ERC20.sol";
import {SafeTransferLib} from "solmate/utils/SafeTransferLib.sol";

import {ERC20Mock} from "./ERC20Mock.sol";

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

contract MooniswapPoolMock is IPool {
    using SafeTransferLib for ERC20;

    uint private _amountOut;

    function setAmountOut(uint to) external {
        _amountOut = to;
    }

    //--------------------------------------------------------------------------
    // IPool Functions

    function getReturn(address src, address dst, uint amount)
        external
        view
        returns (uint)
    {
        return _amountOut;
    }

    function swap(
        address src,
        address dst,
        uint256 amount,
        uint256 minReturn,
        address referral
    ) external payable returns(uint) {
        require(referral == address(0));

        ERC20(src).safeTransferFrom(msg.sender, address(this), amount);

        uint balance = ERC20(dst).balanceOf(address(this));
        if (balance < _amountOut) {
            ERC20Mock(dst).mint(address(this), _amountOut - balance);
        }

        ERC20(dst).safeTransfer(msg.sender, _amountOut);
    }

}
