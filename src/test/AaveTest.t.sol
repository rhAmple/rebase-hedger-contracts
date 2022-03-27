// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.10;

import "ds-test/test.sol";

import "../Aave.sol";

import "forge-std/stdlib.sol";
import "forge-std/Vm.sol";

import {ERC20Mock} from "./utils/mocks/ERC20Mock.sol";
import {AaveLendingPoolMock} from "./utils/mocks/AaveLendingPoolMock.sol";
import {ExchangeMock} from "./utils/mocks/ExchangeMock.sol";

/**
 * @dev Root contract for Aave Test Contracts.
 *
 *      Provides the setUp function, access to common test utils and common
 *      constants.
 */
abstract contract AaveTest is DSTest {
    Vm internal constant vm = Vm(HEVM_ADDRESS);

    // SuT
    Aave aave;

    // Mocks
    ERC20Mock ample;
    ERC20Mock aAmple;
    AaveLendingPoolMock lendingPool;
    ExchangeMock exchange;

    function setUp() public {
        ample = new ERC20Mock("AMPL", "Ample", uint8(9));
        aAmple = new ERC20Mock("aAMPL", "aAmple", uint8(9));

        lendingPool = new AaveLendingPoolMock(address(aAmple));

        exchange = new ExchangeMock(address(ample), address(aAmple));

        aave = new Aave(
            address(ample),
            address(aAmple),
            address(lendingPool),
            address(exchange)
        );
    }

    function overflows(uint a, uint b) public pure returns (bool) {
        unchecked {
            uint x = a + b;
            return x < a || x < b;
        }
    }

}
