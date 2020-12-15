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

T lerp(T, U)(const T from, const T to, const U amount)
{
    return cast(T) (from + amount * (to - from));
}
T lerp(T, U)(const T[2] fromTo, const U amount)
{
    return lerp(fromTo[0], fromTo[1], amount);
}
