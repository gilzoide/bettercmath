module bettercmath.valuerange;

import bettercmath.misc : lerp;

T remap(T)(const T value, const T inputStart, const T inputEnd, const T outputStart, const T outputEnd)
{
    return (value - inputStart) / (inputEnd - inputStart) * (outputEnd - outputStart) + outputStart;
}

T remap(T)(const T value, const ValueRange!T input, const ValueRange!T output)
{
    return remap(value, input.from, input.to, output.from, output.to);
}

struct ValueRange(T)
{
    T from = 0, to = 1;

    T lerp(U)(const U amount) const
    {
        return .lerp(from, to, amount);
    }

    T remap(const T value, const ValueRange newRange) const
    {
        return .remap(value, this, newRange);
    }

    T normalize(const T value) const
    {
        return (value - from) / (to - from);
    }

    T distance() const
    {
        return to - from;
    }
}

alias IntRange = ValueRange!int;
alias FloatRange = ValueRange!float;
alias DoubleRange = ValueRange!double;
