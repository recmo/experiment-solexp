// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

library FixedPointMathLib {
        // 1
    int256 private constant FIXED_1 = int256(0x0000000000000000000000000000000080000000000000000000000000000000);
    // 0
    int256 private constant EXP_MAX_VAL = 0;
    // -63.875
    int256 private constant EXP_MIN_VAL = -int256(0x0000000000000000000000000000001ff0000000000000000000000000000000);

    function expWad(int256 x) internal pure returns (uint256 z) {
        unchecked {
            assembly {
                // Revert if the exponent x is greater than 130e18 or less than -41e18.
                if or(sgt(x, 130000000000000000000), slt(x, sub(0, 41000000000000000000))) {
                    revert(0, 0)
                }
            }

            if (x < 0) {
                z = expWad(-x); // Compute exp for x as a positive.

                assembly {
                    // Divide it by 1e36, to get the inverse of the result.
                    z := div(1000000000000000000000000000000000000, z)
                }

                return z;
            }

            z = 1; // 1 unscaled. Will get overridden if x is large.

            if (x >= 128000000000000000000) {
                x -= 128000000000000000000; // 2ˆ7 scaled by 1e18.

                z = 38877084059945950922200000000000000000000000000000000000; // eˆ12800000000000000000 unscaled.
            } else if (x >= 64000000000000000000) {
                x -= 64000000000000000000; // 2^6 scaled by 1e18.

                z = 6235149080811616882910000000; // eˆ64000000000000000000 unscaled.
            }

            x *= 100; // Scale x to 20 decimals for extra precision.

            uint256 product = 1e20; // Stores a 20 decimal fixed point number.

            assembly {
                if iszero(lt(x, 3200000000000000000000)) {
                    x := sub(x, 3200000000000000000000) // 2ˆ5 scaled by 1e18.

                    // Multiplied by eˆ3200000000000000000000 scaled by 1e20 and divided by 1e20.
                    product := div(mul(product, 7896296018268069516100000000000000), 100000000000000000000)
                }

                if iszero(lt(x, 1600000000000000000000)) {
                    x := sub(x, 1600000000000000000000) // 2ˆ4 scaled by 1e18.

                    // Multiplied by eˆ16000000000000000000 scaled by 1e20 and divided by 1e20.
                    product := div(mul(product, 888611052050787263676000000), 100000000000000000000)
                }

                if iszero(lt(x, 800000000000000000000)) {
                    x := sub(x, 800000000000000000000) // 2ˆ3 scaled by 1e18.

                    // Multiplied by eˆ8000000000000000000 scaled by 1e20 and divided by 1e20.
                    product := div(mul(product, 2980957987041728274740004), 100000000000000000000)
                }

                if iszero(lt(x, 400000000000000000000)) {
                    x := sub(x, 400000000000000000000) // 2ˆ2 scaled by 1e18.

                    // Multiplied by eˆ4000000000000000000 scaled by 1e20 and divided by 1e20.
                    product := div(mul(product, 5459815003314423907810), 100000000000000000000)
                }

                if iszero(lt(x, 200000000000000000000)) {
                    x := sub(x, 200000000000000000000) // 2ˆ1 scaled by 1e18.

                    // Multiplied by eˆ2000000000000000000 scaled by 1e20 and divided by 1e20.
                    product := div(mul(product, 738905609893065022723), 100000000000000000000)
                }

                if iszero(lt(x, 100000000000000000000)) {
                    x := sub(x, 100000000000000000000) // 2ˆ0 scaled by 1e18.

                    // Multiplied by eˆ1000000000000000000 scaled by 1e20 and divided by 1e20.
                    product := div(mul(product, 271828182845904523536), 100000000000000000000)
                }

                if iszero(lt(x, 50000000000000000000)) {
                    x := sub(x, 50000000000000000000) // 2ˆ-1 scaled by 1e18.

                    // Multiplied by eˆ5000000000000000000 scaled by 1e20 and divided by 1e20.
                    product := div(mul(product, 164872127070012814685), 100000000000000000000)
                }

                if iszero(lt(x, 25000000000000000000)) {
                    x := sub(x, 25000000000000000000) // 2ˆ-2 scaled by 1e18.

                    // Multiplied by eˆ250000000000000000 scaled by 1e20 and divided by 1e20.
                    product := div(mul(product, 128402541668774148407), 100000000000000000000)
                }
            }

            // We'll use the Taylor series for e^x like 1 + x + (x^2 / 2!) + ... + (x^n / n!).
            uint256 term = uint256(x); // Will track each term in the series, beginning with x.
            uint256 sum = 1e20 + term; // The Taylor series begins with 1 plus the first term, x.

            assembly {
                term := div(mul(term, x), 200000000000000000000) // Divided by 2e20.
                sum := add(sum, term)

                term := div(mul(term, x), 300000000000000000000) // Divided by 3e20.
                sum := add(sum, term)

                term := div(mul(term, x), 400000000000000000000) // Divided by 4e20.
                sum := add(sum, term)

                term := div(mul(term, x), 500000000000000000000) // Divided by 5e20.
                sum := add(sum, term)

                term := div(mul(term, x), 600000000000000000000) // Divided by 6e20.
                sum := add(sum, term)

                term := div(mul(term, x), 700000000000000000000) // Divided by 7e20.
                sum := add(sum, term)

                term := div(mul(term, x), 800000000000000000000) // Divided by 8e20.
                sum := add(sum, term)

                term := div(mul(term, x), 900000000000000000000) // Divided by 9e20.
                sum := add(sum, term)

                term := div(mul(term, x), 1000000000000000000000) // Divided by 10e20.
                sum := add(sum, term)

                term := div(mul(term, x), 1100000000000000000000) // Divided by 11e20.
                sum := add(sum, term)

                term := div(mul(term, x), 1200000000000000000000) // Divided by 12e20.
                sum := add(sum, term)
            }

            return (((product * sum) / 1e20) * z) / 100; // Divided by 100 to scale back to 18 decimals.
        }
    }

    /// @dev Compute the natural exponent for a fixed-point number EXP_MIN_VAL <= `x` <= EXP_MAX_VAL
    function exp(int256 x) internal pure returns (int256 r) { unchecked {
        if (x < EXP_MIN_VAL) {
            // Saturate to zero below EXP_MIN_VAL.
            return 0;
        }
        if (x == 0) {
            return FIXED_1;
        }
        require(
            x <= EXP_MAX_VAL,
            "VALUE_TOO_LARGE"
        );

        // Rewrite the input as a product of natural exponents and a
        // single residual q, where q is a number of small magnitude.
        // For example: e^-34.419 = e^(-32 - 2 - 0.25 - 0.125 - 0.044)
        //              = e^-32 * e^-2 * e^-0.25 * e^-0.125 * e^-0.044
        //              -> q = -0.044

        // y = x % 0.125 (the residual)
        int256 y = x % 0x0000000000000000000000000000000010000000000000000000000000000000;
        // Chebyshev approximation on (0, 0.125) deg 17.
        // Max observed error 5.9e-39, last 0 bits.
        y -= 0x8000000000000000000000000000000; // 0.0625
        r = 0x729257631587063e249ff; // 5.09e-14
        r = ((r * y) / FIXED_1) + 0x729257631587063e249ff; // 5.09e-14
        r = ((r * y) / FIXED_1) + 0x72928a4ec10f332feaad08; // 8.14e-13
        r = ((r * y) / FIXED_1) + 0x6b67b4051803077618e97fd; // 1.22e-11
        r = ((r * y) / FIXED_1) + 0x5dfabd83c2c9d04f969b2bb9; // 1.71e-10
        r = ((r * y) / FIXED_1) + 0x4c5bb9fd99e4276d168f24c94; // 2.22e-09
        r = ((r * y) / FIXED_1) + 0x3944cb7e336c15ceaeb49c6d65; // 2.67e-08
        r = ((r * y) / FIXED_1) + 0x275f4be6c3584f004dd1ce0cd2c; // 2.93e-07
        r = ((r * y) / FIXED_1) + 0x189b8f703a17315f81990a82a490; // 2.93e-06
        r = ((r * y) / FIXED_1) + 0xdd780af20ad0bc6966ef13ed0f22; // 2.64e-05
        r = ((r * y) / FIXED_1) + 0x6ebc057905685e34b37ba432f9179; // 0.000211
        r = ((r * y) / FIXED_1) + 0x30724264f25da9370e82dcc672da8a; // 0.00148
        r = ((r * y) / FIXED_1) + 0x122ad8e5dae31f74a57112c9a292113; // 0.00887
        r = ((r * y) / FIXED_1) + 0x5ad63c7d466f9d473b355df60c99bf5; // 0.0444
        r = ((r * y) / FIXED_1) + 0x16b58f1f519be751cecd577d83277b28; // 0.177
        r = ((r * y) / FIXED_1) + 0x4420ad5df4d3b5f56c68067889726a54; // 0.532
        r = ((r * y) / FIXED_1) + 0x88415abbe9a76bead8d00cf112e4d4a2; // 1.06
        r = ((r * y) / FIXED_1) + 0x88415abbe9a76bead8d00cf112e4d4a9; // 1.06

        // Multiply with the non-residual terms.
        x = -x;
        // e ^ -32
        if ((x & int256(0x0000000000000000000000000000001000000000000000000000000000000000)) != 0) {
            r = (r * int256(0x00000000000000000000000000000000000000f1aaddd7742e56d32fb9f99744)) /
                int256(0x0000000000000000000000000043cbaf42a000812488fc5c220ad7b97bf6e99e); // * e ^ -32
        }
        // e ^ -16
        if ((x & int256(0x0000000000000000000000000000000800000000000000000000000000000000)) != 0) {
            r = (r * int256(0x00000000000000000000000000000000000afe10820813d65dfe6a33c07f738f)) /
                int256(0x000000000000000000000000000005d27a9f51c31b7c2f8038212a0574779991); // * e ^ -16
        }
        // e ^ -8
        if ((x & int256(0x0000000000000000000000000000000400000000000000000000000000000000)) != 0) {
            r = (r * int256(0x0000000000000000000000000000000002582ab704279e8efd15e0265855c47a)) /
                int256(0x0000000000000000000000000000001b4c902e273a58678d6d3bfdb93db96d02); // * e ^ -8
        }
        // e ^ -4
        if ((x & int256(0x0000000000000000000000000000000200000000000000000000000000000000)) != 0) {
            r = (r * int256(0x000000000000000000000000000000001152aaa3bf81cb9fdb76eae12d029571)) /
                int256(0x00000000000000000000000000000003b1cc971a9bb5b9867477440d6d157750); // * e ^ -4
        }
        // e ^ -2
        if ((x & int256(0x0000000000000000000000000000000100000000000000000000000000000000)) != 0) {
            r = (r * int256(0x000000000000000000000000000000002f16ac6c59de6f8d5d6f63c1482a7c86)) /
                int256(0x000000000000000000000000000000015bf0a8b1457695355fb8ac404e7a79e3); // * e ^ -2
        }
        // e ^ -1
        if ((x & int256(0x0000000000000000000000000000000080000000000000000000000000000000)) != 0) {
            r = (r * int256(0x000000000000000000000000000000004da2cbf1be5827f9eb3ad1aa9866ebb3)) /
                int256(0x00000000000000000000000000000000d3094c70f034de4b96ff7d5b6f99fcd8); // * e ^ -1
        }
        // e ^ -0.5
        if ((x & int256(0x0000000000000000000000000000000040000000000000000000000000000000)) != 0) {
            r = (r * int256(0x0000000000000000000000000000000063afbe7ab2082ba1a0ae5e4eb1b479dc)) /
                int256(0x00000000000000000000000000000000a45af1e1f40c333b3de1db4dd55f29a7); // * e ^ -0.5
        }
        // e ^ -0.25
        if ((x & int256(0x0000000000000000000000000000000020000000000000000000000000000000)) != 0) {
            r = (r * int256(0x0000000000000000000000000000000070f5a893b608861e1f58934f97aea57d)) /
                int256(0x00000000000000000000000000000000910b022db7ae67ce76b441c27035c6a1); // * e ^ -0.25
        }
        // e ^ -0.125
        if ((x & int256(0x0000000000000000000000000000000010000000000000000000000000000000)) != 0) {
            r = (r * int256(0x00000000000000000000000000000000783eafef1c0a8f3978c7f81824d62ebf)) /
                int256(0x0000000000000000000000000000000088415abbe9a76bead8d00cf112e4d4a8); // * e ^ -0.125
        }
    }}


}
