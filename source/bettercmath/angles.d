module bettercmath.angles;

import bettercmath.cmath : FloatType;
import std.math : PI;

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
