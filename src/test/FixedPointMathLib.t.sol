// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import "ds-test/test.sol";
import "../FixedPointMathLib.sol";

contract FixedPointMathLibTest is DSTest {
    function setUp() public {}

    function testExp() public {
        assertEq(FixedPointMathLib.expWad(-1e18), 367879441171442321);
    }

    function testExp2() public {
        FixedPointMathLib.exp(-1e18);
    }
}
