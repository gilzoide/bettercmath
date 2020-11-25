module bettercmath.cmath;

import cmath = core.stdc.math;
import dmath = std.math;
import std.meta : AliasSeq;
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

private enum functions = AliasSeq!(
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
);

static foreach (f; functions)
{
    mixin(q{alias } ~ f ~ q{ = MathFunc!} ~ "\"" ~ f ~ "\";");
}

// Private helpers for templated math function calls
private string cfuncname(T : double, string f)()
{
    return f;
}
private string cfuncname(T : real, string f)()
{
    return f ~ "l";
}
private string cfuncname(T : float, string f)()
{
    return f ~ "f";
}
private string cfuncname(T : int, string f)()
{
    return f ~ "f";
}

private struct MathFunc(string f)
{
    template opCall(T, Args...)
    {
        import std.traits : ReturnType;
        private alias dfunc = __traits(getMember, dmath, f);
        private alias cfunc = __traits(getMember, cmath, cfuncname!(T, f)());

        nothrow @nogc static ReturnType!cfunc opCall(T arg1, Args args)
        {
            if (__ctfe)
            {
                // Use D functions on CTFE
                return dfunc(cast(FloatType!T) arg1, args);
            }
            else
            {
                // Use the appropriate C function on runtime
                return cfunc(arg1, args);
            }
        }
    }
}

