module bettercmath.angles;

import std.math : PI;

import bettercmath.cmath : FloatType;

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
