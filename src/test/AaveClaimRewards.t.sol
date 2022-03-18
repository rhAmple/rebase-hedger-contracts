// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.10;

import "./AaveTest.t.sol";

/**
 * @dev Aave Claim Reward Tests.
 */
contract AaveClaimRewards is AaveTest {

    function testClaimRewards() public {
        EVM.expectRevert("Claiming not implemented");
        aave.claimRewards(address(0));

        emit log_string("Reward claiming not yet implemented");
    }

}
