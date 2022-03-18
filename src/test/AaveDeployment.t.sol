// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.10;

import "./AaveTest.t.sol";

/**
 * @dev Aave Deployment Tests.
 */
contract AaveDeployment is AaveTest {

    function testConstructor() public {
        // Constructor arguments.
        assertEq(aave.ample(), address(ample));
        assertEq(aave.token(), address(aAmple));
        assertEq(aave.lendingPool(), address(lendingPool));
        assertEq(aave.exchange(), address(exchange));

        // Infinite Ample allowance given to lending pool.
        assertEq(
            ample.allowance(address(aave), address(lendingPool)),
            type(uint).max
        );

        // Inifinte aAmple allowance given to exchange.
        assertEq(
            aAmple.allowance(
                address(aave), address(exchange)
            ),
            type(uint).max
        );
    }

}
