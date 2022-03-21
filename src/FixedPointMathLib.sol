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

    // Computes e^x in 1e18 fixed point.
    // Consumes 456 gas.
    function exp(int256 x) internal returns (int256) { unchecked {
        // Input x is in fixed point format, with scale factor 1/1e18.

        // When the result is < 0.5 we return zero. This happens when
        // x <= floor(log(0.5e18) * 1e18) ~ -42e18
        if (x <= -42139678854452767551) {
            return 0;
        }

        // When the result is > (2**255 - 1) / 1e18 we can not represent it
        // as an int256. This happens when x >= floor(log((2**255 -1) / 1e18) * 1e18) ~ 135.
        if (x >= 135305999368893231589) {
            revert("Overflow");
        }

        // x is now in the range (-42, 136) * 1e18. Convert to (-42, 136) * 2**96
        // for more intermediate precision and a binary basis. This base conversion
        // is a multiplication by 1e18 / 2**96 = 5**18 / 2**78.
        x = (x << 78) / 5**18;

        // Reduce range of x to (-½ ln 2, ½ ln 2) * 2**96 by factoring out powers of two
        // such that exp(x) = exp(x') * 2**k, where k is an integer.
        // Solving this gives k = round(x / log(2)) and x' = x - k * log(2).
        int256 k = ((x << 96) / 54916777467707473351141471128 + 2**95) >> 96;
        x = x - k * 54916777467707473351141471128;
        // k is in the range [-61, 195].

        // Evaluate using a (6, 7)-term rational approximation
        // TODO: Use pre-processed polynomial evaluation.
        // p is made monic, we will multiply by a scale factor later
        int256 p = x      +     2772001395605857295435445496992;
        p = (p * x >> 96) +    44335888930127919016834873520032;
        p = (p * x >> 96) +   398888492587501845352592340339721;
        p = (p * x >> 96) +  1993839819670624470859228494792842;
        p = p * x         + (4385272521454847904632057985693276 << 96);
        // We leave p in 2**192 basis so we don't need to scale it back up for the division.
        int256 q = x      -      2855989394907223263936484059900;
        q = (q * x >> 96) +     50020603652535783019961831881945;
        q = (q * x >> 96) -    533845033583426703283633433725380;
        q = (q * x >> 96) +   3604857256930695427073651918091429;
        q = (q * x >> 96) -  14423608567350463180887372962807573;
        q = (q * x >> 96) +  26449188498355588339934803723976023;
       int256 r;
        assembly {
            // Div in assembly because solidity adds a zero check despite the `unchecked`.
            // The q polynomial is known not to have zeros in the domain. (All roots are complex)
            // No scaling required because p is already 2**96 too large.
            r := sdiv(p, q)
        }
        // r should be in the range (0.09, 0.25) * 2**96.

        // We now need to multiply r by 
        //  * the scale factor s = ~6.031367120...,
        //  * the 2**k factor from the range reduction, and
        //  * the 1e18 / 2**96 factor for base converison.
        // We do all of this at once, with an intermediate result in 2**213 basis
        // so the final right shift is always by a positive amount.
        r = (r * 3822833074963236453042738258902158003155416615667) >> uint256((117 + 78) - k);

        return r;
    }}
}
