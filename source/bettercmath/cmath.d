module bettercmath.cmath;

import cmath = core.stdc.math;
import std.traits : isFloatingPoint, isNumeric;

enum functions = [
    "acos",
    "asin",
    "atan",
    "atan2",
    "cos",
    "sin",
    "tan",
    "acosh",
    "asinh",
    "atanh",
    "cosh",
    "sinh",
    "tanh",
    "exp",
    "exp2",
    "expm1",
    "frexp",
    "ilogb",
    "ldexp",
    "log",
    "log10",
    "log1p",
    "log2",
    "logb",
    "modf",
    "scalbn",
    "scalbln",
    "cbrt",
    "fabs",
    "hypot",
    "pow",
    "sqrt",
    "erf",
    "erfc",
    "lgamma",
    "tgamma",
    "ceil",
    "floor",
    "nearbyint",
    "rint",
    "lrint",
    "llrint",
    "round",
    "lround",
    "llround",
    "trunc",
    "fmod",
    "remainder",
    "remquo",
    "copysign",
    "nan",
    "nextafter",
    "nexttoward",
    "fdim",
    "fmax",
    "fmin",
    "fma",
];
static foreach (f; functions)
{
    mixin(q{alias } ~ f ~ q{(T : int) = cmath.} ~ f ~ "f;");
    mixin(q{alias } ~ f ~ q{(T : float) = cmath.} ~ f ~ "f;");
    mixin(q{alias } ~ f ~ q{(T : double) = cmath.} ~ f ~ ";");
    mixin(q{alias } ~ f ~ q{(T : real) = cmath.} ~ f ~ "l;");
}

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
