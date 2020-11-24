module bettercmath.vector;

import bettercmath.cmath;
import std.algorithm : among, sum;
import std.traits : isFloatingPoint;

@safe @nogc pure nothrow:

version (unittest)
{
    private alias Vec2 = Vector!(float, 2);
    private alias Vec2i = Vector!(int, 2);
    private alias Vec3 = Vector!(float, 3);
    private alias Vec4 = Vector!(float, 4);
}


/++
 + TODO: doc
 +/
struct Vector(T, uint N)
if (N > 1)
{
    /// Element array.
    T[N] elements = 0;
    alias elements this;

    private ref inout(T) _get(int i)() inout
    in
    {
        assert(i >= 0 && i <= N, "Index out of bounds");
    }
    do
    {
        return elements[i];
    }
    private ref inout(T[to - from]) _slice(int from, int to)() inout
    in
    {
        assert(from >= 0 && to <= N, "Index out of bounds");
    }
    do
    {
        return elements[from .. to];
    }

    alias x = _get!(0);
    alias r = x;
    alias u = x;
    alias s = x;

    alias y = _get!(1);
    alias g = y;
    alias v = y;
    alias t = y;

    static if (N > 2)
    {
        alias z = _get!(2);
        alias b = z;
        alias p = z;

        alias xy = _slice!(0, 2);
        alias rg = xy;
        alias uv = xy;
        alias st = xy;

        alias yz = _slice!(1, 3);
        alias gb = yz;
        alias tp = yz;
    }
    static if (N > 3)
    {
        alias w = _get!(3);
        alias a = w;
        alias q = w;

        alias zw = _slice!(2, 4);
        alias ba = zw;
        alias pq = zw;

        alias xyz = _slice!(0, 3);
        alias rgb = xyz;
        alias stp = xyz;

        alias yzw = _slice!(1, 4);
        alias gba = yzw;
        alias tpq = yzw;
    }

    unittest
    {
        Vec2 v = [1, 2];
        assert(v.x == 1);
        assert(v.x == v[0]);
        assert(v.y == 2);
        assert(v.y == v[1]);
        v.x = 2;
        assert(v.r == 2);
    }

    /// Constructs a Vector with all elements equal to `scalar`
    this(const T scalar)
    {
        elements[] = scalar;
    }
    /// Constructs a Vector with all elements initialized separetely
    this(Args...)(const Args args)
    if (args.length == N)
    {
        elements = [args];
    }
    /// Constructs a Vector from static array.
    this(const T[N] values)
    {
        elements[] = values[];
    }

    /// Vector with all zeros
    enum Vector zeros = 0;
    alias zeroes = zeros;
    /// Vector with all ones
    enum Vector ones = 1;

    // Operators
    Vector opUnary(string op)() const
    if (op.among("-", "+", "~"))
    {
        Vector result;
        mixin(q{result =} ~ op ~ q{elements[];});
        return result;
    }
    unittest
    {
        assert(-Vec2(1, -2) == [-1, 2]);
    }

    Vector opBinary(string op)(const T scalar) const
    if (!op.among("~", "<<", ">>", ">>>"))
    {
        Vector result;
        mixin(q{result = elements[]} ~ op ~ q{scalar;});
        return result;
    }
    unittest
    {
        Vec2 a = [1, 2];
        assert(a + 1 == [1f + 1f, 2f + 1f]);
        assert(a - 1 == [1f - 1f, 2f - 1f]);
        assert(a * 2 == [1f * 2f, 2f * 2f]);
        assert(a / 2 == [1f / 2f, 2f / 2f]);
        assert(a % 2 == [1f % 2f, 2f % 2f]);
        assert(a ^^ 2 == [1f ^^ 2f, 2f ^^ 2f]);

        Vec2i b = [1, 2];
        assert((b & 1) == [1 & 1, 2 & 1]);
        assert((b | 1) == [1 | 1, 2 | 1]);
        assert((b ^ 1) == [1 ^ 1, 2 ^ 1]);
    }
    /// TODO: shift operations

    Vector opBinaryRight(string op)(const T scalar) const
    if (!op.among("~", "<<", ">>", ">>>"))
    {
        Vector result;
        mixin(q{result = scalar} ~ op ~ q{elements[];});
        return result;
    }
    unittest
    {
        Vec2 a = [1, 2];
        assert(1 + a == [1f + 1f, 1f + 2f]);
        assert(1 - a == [1f - 1f, 1f - 2f]);
        assert(2 * a == [2f * 1f, 2f * 2f]);
        assert(2 / a == [2f / 1f, 2f / 2f]);
        assert(2 % a == [2f % 1f, 2f % 2f]);
        assert(2 ^^ a == [2f ^^ 1f, 2f ^^ 2f]);

        Vec2i b = [1, 2];
        assert((1 & b) == [1 & 1, 1 & 2]);
        assert((1 | b) == [1 | 1, 1 | 2]);
        assert((1 ^ b) == [1 ^ 1, 1 ^ 2]);
    }

    Vector opBinary(string op)(const Vector other) const
    if (op != "~")
    {
        Vector result;
        mixin(q{result = elements[]} ~ op ~ q{other.elements[];});
        return result;
    }
    unittest
    {
        assert(Vec2(1, 2) + Vec2(3, 4) == [1f+3f, 2f+4f]);
        assert(Vec2(1, 2) - Vec2(3, 4) == [1f-3f, 2f-4f]);
        assert(Vec2(1, 2) * Vec2(3, 4) == [1f*3f, 2f*4f]);
        assert(Vec2(1, 2) / Vec2(3, 4) == [1f/3f, 2f/4f]);
    }

    Vector!(T, N + 1) opBinary(string op : "~")(const T scalar) const
    {
        typeof(return) result;
        result[0 .. N] = elements[];
        result[N] = scalar;
        return result;
    }
    unittest
    {
        Vec2 v = [1, 2];
        assert(v ~ 3 == Vec3(1, 2, 3));
    }
    Vector!(T, N + 1) opBinaryRight(string op : "~")(const T scalar) const
    {
        typeof(return) result;
        result[0] = scalar;
        result[1 .. N + 1] = elements[];
        return result;
    }
    unittest
    {
        Vec2 v = [1, 2];
        Vec3 v2 = 0f ~ v;
        assert(0 ~ v == Vec3(0, 1, 2));
    }

    Vector!(T, N + M) opBinary(string op : "~", M)(T[M] other) const
    {
        typeof(return) result = elements ~ other;
        return result;
    }
    unittest
    {
        Vec2 v1 = [1, 2];
        assert(v1 ~ [3f, 4f] == Vec4(1, 2, 3, 4));
        assert(v1 ~ Vec2(3f, 4f) == Vec4(1, 2, 3, 4));
    }
    Vector!(T, N + M) opBinaryRight(string op : "~", M)(T[M] other) const
    {
        typeof(return) result = other ~ elements;
        return result;
    }
    unittest
    {
        Vec2 v1 = [1, 2];
        assert([3f, 4f] ~ v1 == Vec4(3, 4, 1, 2));
        assert(Vec2(3f, 4f) ~ v1 == Vec4(3, 4, 1, 2));
    }

    Vector!(T2, N) opCast(U : Vector!(T2, N), T2)() const
    {
        typeof(return) result;
        foreach (i; 0 .. N)
        {
            result[i] = cast(T2) elements[i];
        }
        return result;
    }
    unittest
    {
        Vec2i intVec = [1, 2];
        Vec2 floatVec = cast(Vec2) intVec;
        assert(floatVec == Vec2(1f, 2f));
        assert(cast(Vec2i) floatVec == intVec);
    }

    ref Vector opOpAssign(string op)(const T scalar)
    {
        mixin(q{elements = elements[]} ~ op ~ q{scalar;});
        return this;
    }
    ref Vector opOpAssign(string op)(const Self other)
    {
        mixin(q{elements = elements[]} ~ op ~ q{other[];});
        return this;
    }

    unittest
    {
        assert(Vec2.sizeof == Vec2.elements.sizeof);
        assert(Vec3.sizeof == Vec3.elements.sizeof);
        assert(Vec4.sizeof == Vec4.elements.sizeof);

        alias Vec2_100 = Vec2[100];
        assert(Vec2_100.sizeof == 100 * Vec2.elements.sizeof);
    }
}

/// True if `T` is some kind of Vector
enum isVector(T) = is(T: Vector!U, U...);

T dot(T, uint N)(const Vector!(T, N) a, const Vector!(T, N) b)
{
    auto multiplied = a * b;
    return multiplied[].sum;
}

T magnitudeSquared(T, uint N)(const Vector!(T, N) vec)
{
    return dot(vec, vec);
}
unittest
{
    assert(Vec2(0, 0).magnitudeSquared() == 0);
    assert(Vec2(1, 0).magnitudeSquared() == 1);
    assert(Vec2(0, 1).magnitudeSquared() == 1);
    assert(Vec2(1, 1).magnitudeSquared() == 2);
    assert(Vec2(2, 0).magnitudeSquared() == 4);
    assert(Vec2(1, 2).magnitudeSquared() == 5);
}

template magnitude(T, uint N)
{
    private alias FT = FloatType!T;
    FT magnitude(const Vector!(T, N) vec)
    {
        return sqrt!FT(vec.magnitudeSquared());
    }
}
