// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.10;

import "./AaveTest.t.sol";

/**
 * @dev Aave Deposit and Withdraw Tests.
 */
contract AaveDepositWithdraw is AaveTest {

    function testDeposit(uint amount) public {
        // Mint amount of Amples and approve for rebase hedger.
        ample.mint(address(this), amount);
        ample.approve(address(aave), amount);

        // Deposit Amples.
        aave.deposit(amount);

        checkInvariants();

        assertEq(ample.balanceOf(address(this)), 0);
        assertEq(aAmple.balanceOf(address(this)), amount);
    }

    function testWithdraw(uint amountIn, uint amountOut) public {
        // Mint amount of Amples and approve tokens for rebase hedger.
        ample.mint(address(this), amountIn);
        ample.approve(address(aave), amountIn);
        aAmple.approve(address(aave), amountIn);

        // Withdrawal should not fail.
        lendingPool.setShouldWithdrawFail(false);

        // Simulate increase/decrease of tokens deposited.
        lendingPool.setAmountOut(amountOut);

        // Deposit and withdraw Amples.
        aave.deposit(amountIn);
        aave.withdraw(amountIn);

        checkInvariants();

        assertEq(ample.balanceOf(address(this)), amountOut);
        assertEq(aAmple.balanceOf(address(this)), 0);
    }

    function testWithdrawWithExchange(uint amountIn, uint amountOut) public {
        if (overflows(amountIn, amountOut)) {
            return;
        }

        // Mint amount of Amples and approve tokens for rebase hedger.
        ample.mint(address(this), amountIn);
        ample.approve(address(aave), amountIn);
        aAmple.approve(address(aave), amountIn);

        // Withdrawal should fail.
        lendingPool.setShouldWithdrawFail(true);

        // Simulate negative/positive slippage on exchange.
        exchange.setAmountOut(amountOut);

        // Deposit and withdraw Amples.
        aave.deposit(amountIn);
        aave.withdraw(amountIn);

        checkInvariants();

        assertEq(ample.balanceOf(address(this)), amountOut);
        assertEq(aAmple.balanceOf(address(this)), 0);
    }

    function checkInvariants() private {
        // The rebase hedger should never hold tokens.
        assertEq(ample.balanceOf(address(aave)), 0);
        assertEq(aAmple.balanceOf(address(aave)), 0);
    }

}
