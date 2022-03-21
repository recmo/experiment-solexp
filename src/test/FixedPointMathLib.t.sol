// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import "ds-test/test.sol";
import "../FixedPointMathLib.sol";
import "./console.sol";

contract FixedPointMathLibTest is DSTest {
    function setUp() public {}

    // function testExp() public {
    //     assertEq(FixedPointMathLib.expWad(-1e18), 367879441171442321);
    // }

    function testExp1() public {
        FixedPointMathLib.exp_m(-1e18);
    }
    
    function testSmallest() public {
        FixedPointMathLib.exp_m(-42139678854452767550);
    }

    function testLargest() public {
        FixedPointMathLib.exp_m(135305999368893231588);
    }

    function testExp2() public {
        FixedPointMathLib.exp_m(133e18);
        FixedPointMathLib.exp_m(100e18);
        FixedPointMathLib.exp_m(10e18);
        FixedPointMathLib.exp_m(1e18);
        FixedPointMathLib.exp_m(-1e18);
        FixedPointMathLib.exp_m(-23e18);
    }

    function testExpm() public {
        console.logInt(FixedPointMathLib.exp_m(-2.3e18));
        // assertEq(FixedPointMathLib.exp_m(-1e18), 367879441171442321);
    }
}
