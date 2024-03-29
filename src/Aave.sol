// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.10;

import {ERC20} from "solmate/tokens/ERC20.sol";
import {SafeTransferLib} from "solmate/utils/SafeTransferLib.sol";

import {IRebaseHedger} from "rhAmple-contracts/interfaces/IRebaseHedger.sol";

import {IExchange} from "./interfaces/IExchange.sol";

// Aaves lending pool interface.
// Copied from https://docs.aave.com/developers/the-core-protocol/lendingpool/ilendingpool.
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

/**
 * @title The Aave Rebase Hedger
 *
 * @dev A rebase hedger implementation using the Aave lending market to
 *      hedge Amples against negative rebases.
 *
 * @author merkleplant
 */
contract Aave is IRebaseHedger {
    using SafeTransferLib for ERC20;

    //--------------------------------------------------------------------------
    // Storage

    /// @dev The Ample token address.
    ERC20 private immutable _ample;

    /// @dev The aAmple token address.
    ERC20 private immutable _aAmple;

    /// @dev Aave's {ILendingPool} implementation address.
    ILendingPool private immutable _lendingPool;

    /// @dev The {IExchange} implementation address.
    IExchange private immutable _exchange;

    //--------------------------------------------------------------------------
    // Constructor

    constructor(
        address ample_,
        address aAmple_,
        address lendingPool_,
        address exchange_
    ) {
        _ample = ERC20(ample_);
        _aAmple = ERC20(aAmple_);
        _lendingPool = ILendingPool(lendingPool_);
        _exchange = IExchange(exchange_);

        // Give infinite approval of Amples to the {ILendingPool}
        // implementation.
        _ample.approve(lendingPool_, type(uint).max);

        // Give infinite approval of aAmples to the {IExchange} implementation.
        _aAmple.approve(exchange_, type(uint).max);
    }

    //--------------------------------------------------------------------------
    // IRebaseHedger Functions

    /// @inheritdoc IRebaseHedger
    function deposit(uint amples) external override(IRebaseHedger) {
        // Fetch Amples from msg.sender.
        _ample.safeTransferFrom(msg.sender, address(this), amples);

        // Deposit Amples on behalf of msg.sender.
        _lendingPool.deposit(address(_ample), amples, msg.sender, uint16(0));
    }

    /// @inheritdoc IRebaseHedger
    function withdraw(uint amples) external override(IRebaseHedger) {
        // Note that the conversion rate of aAmple:Ample is 1:1.
        uint aAmples = amples;

        // Fetch aAmples from msg.sender.
        _aAmple.safeTransferFrom(msg.sender, address(this), aAmples);

        // Withdraw Amples to msg.sender.
        try _lendingPool.withdraw(address(_ample), aAmples, msg.sender)
            returns (uint /*amount*/)
        {
            // Withdrawal succeded.
            // Note that the Amples were withdrawn to msg.sender and therefore
            // no transfer is necessary.
        } catch {
            // Withdrawal failed.
            // Sell aAmples for Amples using the {IExchange} implementation and
            // send resulting Ample balance to msg.sender.
            _exchange.sell(aAmples);
            _ample.safeTransfer(msg.sender, _ample.balanceOf(address(this)));
        }
    }

    /// @inheritdoc IRebaseHedger
    function balanceOf(address who)
        external
        view
        override(IRebaseHedger)
        returns (uint)
    {
        // Note that the conversion rate of aAmple:Ample is 1:1.
        return _aAmple.balanceOf(who);
    }

    /// @inheritdoc IRebaseHedger
    function claimRewards(address receiver)
        external
        pure
        override(IRebaseHedger)
    {
        // @todo To silence compiler warning during dev.
        //       Check for compiler pragma.
        require(receiver == address(0) || receiver != address(0));

        revert("Claiming not implemented");
    }

    //--------------------------------------------------------------------------
    // Public View Functions

    /// @inheritdoc IRebaseHedger
    function token() external view override(IRebaseHedger) returns (address) {
        return address(_aAmple);
    }

    /// @notice Returns the exchange contract used to sell aAmples in case
    ///         a withdrawal from Aave fails.
    function exchange()
        external
        view
        returns (address)
    {
        return address(_exchange);
    }

    /// @notice Returns Ample's token address.
    function ample() external view returns (address) {
        return address(_ample);
    }

    /// @notice Returns Aave's lending pool implementation address.
    function lendingPool() external view returns (address) {
        return address(_lendingPool);
    }

}
