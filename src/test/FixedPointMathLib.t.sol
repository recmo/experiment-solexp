// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import "ds-test/test.sol";
import "../FixedPointMathLib.sol";
import "./console.sol";

contract FixedPointMathLibTest is DSTest {
    function setUp() public {}

    function testIlog1() public {
        FixedPointMathLib.ilog2(2 ** 196 - 1);
    }

    function testIlog2() public {
        FixedPointMathLib.ilog2(1e18);
        FixedPointMathLib.ilog2(1e20);
    }

    function testIlog() public {
        assertEq(FixedPointMathLib.ilog2(0), 0);
        for(uint256 i = 1; i < 255; i++) {
            assertEq(FixedPointMathLib.ilog2((1 << i) - 1), i - 1);
            assertEq(FixedPointMathLib.ilog2((1 << i)), i);
            assertEq(FixedPointMathLib.ilog2((1 << i) + 1), i);
        }
    }

    function testIlogGas() public {
        uint256 count = 0;
        uint256 sum = 0;
        uint256 sum_sq = 0;
        for(uint256 i = 1; i < 255; i++) {
            uint256 k = (1 << i) - 1;
            uint g0 = gasleft();
            FixedPointMathLib.ilog2(k);
            uint g1 = gasleft();
            sum += g0 - g1;
            sum_sq += (g0 - g1) * (g0 - g1);
            ++count;
            ++k;
            g0 = gasleft();
            FixedPointMathLib.ilog2(k);
            g1 = gasleft();
            sum += g0 - g1;
            sum_sq += (g0 - g1) * (g0 - g1);
            ++count;
            ++k;
            g0 = gasleft();
            FixedPointMathLib.ilog2(k);
            g1 = gasleft();
            sum += g0 - g1;
            sum_sq += (g0 - g1) * (g0 - g1);
            ++count;
        }
        console.Log("gas", sum / count);
        console.Log("gas_var", (sum_sq - sum * sum / count)/ (count - 1));
    }

    function testLn() public {
        assertEq(FixedPointMathLib.ln(1e18), 0);

        // Actual: 999999999999999999.8674576…
        assertEq(FixedPointMathLib.ln(2718281828459045235), 999999999999999999);

        // Actual: 2461607324344817917.963296…
        assertEq(FixedPointMathLib.ln(11723640096265400935), 2461607324344817918);
    }

    function testLnSmall() public {
        // Actual: -41446531673892822312.3238461…
        assertEq(FixedPointMathLib.ln(1), -41446531673892822313);

        // Actual: -37708862055609454006.40601608…
        assertEq(FixedPointMathLib.ln(42), -37708862055609454007);

        // Actual: -32236191301916639576.251880365581…
        assertEq(FixedPointMathLib.ln(1e4), -32236191301916639577);

        // Actual: -20723265836946411156.161923092…
        assertEq(FixedPointMathLib.ln(1e9), -20723265836946411157);
    }

    function testLnBig() public {
        // Actual: 135305999368893231589.070344787…
        assertEq(FixedPointMathLib.ln(2**255 - 1), 135305999368893231589);

        // Actual: 76388489021297880288.605614463571…
        assertEq(FixedPointMathLib.ln(2**170), 76388489021297880288);

        // Actual: 47276307437780177293.081865…
        assertEq(FixedPointMathLib.ln(2**128), 47276307437780177293);
    }

    function testLnGas() public {
        uint256 count = 0;
        uint256 sum = 0;
        uint256 sum_sq = 0;
        for(uint256 i = 1; i < 255; i++) {
            int256 k = int256(1 << i) - 1;
            uint g0 = gasleft();
            FixedPointMathLib.ln(k);
            uint g1 = gasleft();
            sum += g0 - g1;
            sum_sq += (g0 - g1) * (g0 - g1);
            ++count;
            ++k;
            g0 = gasleft();
            FixedPointMathLib.ln(k);
            g1 = gasleft();
            sum += g0 - g1;
            sum_sq += (g0 - g1) * (g0 - g1);
            ++count;
            ++k;
            g0 = gasleft();
            FixedPointMathLib.ln(k);
            g1 = gasleft();
            sum += g0 - g1;
            sum_sq += (g0 - g1) * (g0 - g1);
            ++count;
        }
        console.Log("gas", sum / count);
        console.Log("gas_var", (sum_sq - sum * sum / count)/ (count - 1));
    }

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
