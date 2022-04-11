// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "./test/console.sol";

library FixedPointMathLib {

    error Overflow();
    error LnNegativeUndefined();

    function ilog2_pub(uint256 x) public returns (uint256 r) {
        return ilog2(x);
    }

    // Integer log2 (alternative implementation)
    // @returns floor(log2(x)) if x is nonzero, otherwise 0.
    // Consumes 317 gas. This could have been an 3 gas EVM opcode though.
    function ilog2_alt(uint256 x) internal returns (uint256 r) {
        unchecked {
            // Repeat first zero all the way to the right
            x |= x >> 1;
            x |= x >> 2;
            x |= x >> 4;
            x |= x >> 8;
            x |= x >> 16;
            x |= x >> 32;
            x |= x >> 64;
            x |= x >> 128;

            // Count 32 bit chunks
            r = x & 0x100000001000000010000000100000001000000010000000100000001;
            r *= 0x20000000200000002000000020000000200000002000000020;
            r >>= 224;

            // Extract highest bit
            x ^= x >> 1;

            // Copy to lowest 32 bit chunk
            x |= x >> 32;
            x |= x >> 64;
            x |= x >> 128;
            // No need to clear the other chunks

            // Map to 0-31 using the B(2, 5) de Bruijn sequence 0x077CB531.
            // See <https://en.wikipedia.org/wiki/De_Bruijn_sequence#Finding_least-_or_most-significant_set_bit_in_a_word>
            x = ((x * 0x077CB531) >> 27) & 0x1f;

            // Use a bytes32 32 entry lookup table
            assembly {
                // Need assembly here because solidity introduces an uncessary bounds
                // check.
                r := add(r, byte(x, 0x11c021d0e18031e16140f191104081f1b0d17151310071a0c12060b050a09))
            }
        }
    }

    // Integer log2
    // @returns floor(log2(x)) if x is nonzero, otherwise 0. This is the same
    //          as the location of the highest set bit.
    // Consumes 232 gas. This could have been an 3 gas EVM opcode though.
    function ilog2(uint256 x) internal returns (uint256 r) {
        assembly {
            r := shl(7, lt(0xffffffffffffffffffffffffffffffff, x))
            r := or(r, shl(6, lt(0xffffffffffffffff, shr(r, x))))
            r := or(r, shl(5, lt(0xffffffff, shr(r, x))))
            r := or(r, shl(4, lt(0xffff, shr(r, x))))
            r := or(r, shl(3, lt(0xff, shr(r, x))))
            r := or(r, shl(2, lt(0xf, shr(r, x))))
            r := or(r, shl(1, lt(0x3, shr(r, x))))
            r := or(r, lt(0x1, shr(r, x)))
        }
    }

    // Computes ln(x) in 1e18 fixed point.
    function ln(int256 x) internal returns (int256 r) { unchecked {
        if (x < 0) revert LnNegativeUndefined();
        if (x < 1) revert Overflow();
        console.logInt(x);

        // Reduce range of x to (1, 2) * 2**96
        // ln(2^k * x) = k * ln(2) + ln(x)
        int256 k = int256(ilog2(uint256(x))) - 96;
        console.logInt(k);
        if (k > 0) {
            x >>= uint256(k);
        } else {
            x <<= uint256(-k);
        }
        console.logInt(x);

        // r = k * ln(2) * 1e18
        r = 693147180559945309 * k;
    }}

    // Computes e^x in 1e18 fixed point.
    function exp(int256 x) internal pure returns (int256 r) { unchecked {
        // Input x is in fixed point format, with scale factor 1/1e18.

        // When the result is < 0.5 we return zero. This happens when
        // x <= floor(log(0.5e18) * 1e18) ~ -42e18
        if (x <= -42139678854452767551) {
            return 0;
        }

        // When the result is > (2**255 - 1) / 1e18 we can not represent it
        // as an int256. This happens when x >= floor(log((2**255 -1) / 1e18) * 1e18) ~ 135.
        if (x >= 135305999368893231589) revert Overflow();

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
        // p is made monic, we will multiply by a scale factor later
        int256 p = x      +     2772001395605857295435445496992;
        p = (p * x >> 96) +    44335888930127919016834873520032;
        p = (p * x >> 96) +   398888492587501845352592340339721;
        p = (p * x >> 96) +  1993839819670624470859228494792842;
        p = p * x         + (4385272521454847904632057985693276 << 96);
        // We leave p in 2**192 basis so we don't need to scale it back up for the division.
        // Evaluate using using Knuth's scheme from p. 491.
        int256 z = x      +     750530180792738023273180420736;
        z = (z * x >> 96) +   32788456221302202726307501949080;
        int256 w = x      -    2218138959503481824038194425854;
        w = (w * z >> 96) +  892943633302991980437332862907700;
        int256 q = z + w  -   78174809823045304726920794422040;
        q = (q * w >> 96) + 4203224763890128580604056984195872;
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
        r = int((uint(r) * 3822833074963236453042738258902158003155416615667) >> uint256(195 - k));
    }}
}
