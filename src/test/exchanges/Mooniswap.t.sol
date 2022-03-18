// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.10;

import "./ExchangeTest.t.sol";

import {Mooniswap} from "../../exchanges/Mooniswap.sol";

import {MooniswapPoolMock} from "../utils/mocks/MooniswapPoolMock.sol";

/**
 * @dev Mooniswap Tests.
 */
contract MooniswapTest is ExchangeTest {

    // SuT
    Mooniswap exchange;

    // Mocks
    MooniswapPoolMock pool;

    function setUp() public override(ExchangeTest) {
        super.setUp();

        pool = new MooniswapPoolMock();

        exchange = new Mooniswap(
            address(ample),
            address(sellToken),
            address(pool)
        );
    }

    function testDeployment() public override(ExchangeTest) {
        assertEq(exchange.ample(), address(ample));
        assertEq(exchange.sellToken(), address(sellToken));
        assertEq(exchange.pool(), address(pool));

        // Infinite sellToken allowance given to pool.
        assertEq(
            sellToken.allowance(address(exchange), address(pool)),
            type(uint).max
        );
    }

    function testSell(uint amountIn, uint amountOut) public override(ExchangeTest) {
        // Mint amount of sellTokens and approve them for Mooniswap.
        sellToken.mint(address(this), amountIn);
        sellToken.approve(address(exchange), amountIn);

        // Simulate negative/positive slippage.
        pool.setAmountOut(amountOut);

        // Sell Amples.
        exchange.sell(amountIn);

        checkInvariants();

        assertEq(ample.balanceOf(address(this)), amountOut);
        assertEq(sellToken.balanceOf(address(this)), 0);
    }

    function checkInvariants() internal {
        // The exchange should never hold tokens.
        assertEq(ample.balanceOf(address(exchange)), 0);
        assertEq(sellToken.balanceOf(address(exchange)), 0);
    }

}
