// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.10;

import "ds-test/test.sol";

import "../../exchanges/Exchange.sol";

import {HEVM} from "../utils/HEVM.sol";
import {ERC20Mock} from "../utils/mocks/ERC20Mock.sol";

/**
 * @dev Root contract for Exchange Test Contracts.
 *
 *      Provides a setUp, the token mocks and a set of tests Exchange Test
 *      Contracts have to implement.
 */
abstract contract ExchangeTest is DSTest {
    HEVM internal constant EVM = HEVM(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    // Mocks
    ERC20Mock ample;
    ERC20Mock sellToken;

    function setUp() public virtual {
        ample = new ERC20Mock("AMPL", "Ample", uint8(9));
        sellToken = new ERC20Mock("SELL", "sell Token", uint8(9));
    }

    function testDeployment() public virtual;

    function testSell(uint amountIn, uint amountOut) public virtual;

}
