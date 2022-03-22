// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import "ds-test/test.sol";
import "../FixedPointMathLib.sol";
import "./console.sol";

contract FixedPointMathLibTest is DSTest {
    function setUp() public {}

    function testExp1() public {
        assertEq(FixedPointMathLib.exp(-1e18), 367879441171442321);
    }
    
    function testSmallest() public {
        FixedPointMathLib.exp(-42139678854452767550);
    }

    function testLargest() public {
        FixedPointMathLib.exp(135305999368893231588);
    }

    function testSome() public {
        console.logInt(FixedPointMathLib.exp(5e18));
    }

    function testExpGas() public {
        uint g0 = gasleft();
        FixedPointMathLib.exp(133e18);
        uint g1 = gasleft();
        FixedPointMathLib.exp(-23e18);
        uint g2 = gasleft();
        FixedPointMathLib.exp(5e18);
        uint g3 = gasleft();
        console.logUint(g0 - g1);
        console.logUint(g1 - g2);
        console.logUint(g2 - g3);
    }

    function testExp3() public {
        FixedPointMathLib.exp(133e18);
        FixedPointMathLib.exp(10e18);
        FixedPointMathLib.exp(-23e18);
    }
}
