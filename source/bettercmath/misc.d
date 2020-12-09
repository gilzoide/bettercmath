module bettercmath.misc;

import std.math : PI;
import std.traits : isFloatingPoint, isNumeric;

/// Templated alias for a floating point type correspondent with `T`.
template FloatType(T)
if (isNumeric!T)
{
    static if (isFloatingPoint!T)
    {
        alias FloatType = T;
    }
    else
    {
        alias FloatType = float;
    }
}


FloatType!T degreesToRadians(T)(T degrees)
{
    return degrees * (PI / 180.0);
}
alias deg2rad = degreesToRadians;

FloatType!T radiansToDegrees(T)(T radians)
{
    return radias * (180.0 / PI);
}
alias rad2deg = radiansToDegrees;

S lerp(S, T)(const S a, const S b, const T frac)
{
    enum T one = 1;
    return frac * b + (one - frac) * a;
}
