/**
 * Type and dimension generic Vector backed by a static array.
 */
module bettercmath.vector;

import std.algorithm : among, copy, max, min, sum;
import std.range;
import std.traits : isFloatingPoint;

import bettercmath.cmath;
import bettercmath.misc : FloatType;
public import bettercmath.misc : lerp;

@safe @nogc nothrow:

version (unittest)
{
    private alias Vec1 = Vector!(float, 1);
    private alias Vec2 = Vector!(float, 2);
    private alias Vec2i = Vector!(int, 2);
    private alias Vec3 = Vector!(float, 3);
    private alias Vec4 = Vector!(float, 4);
}


/**
 * Generic Vector backed by a static array.
 * 
 * Params:
 *   T = Element type
 *   N = Vector dimension, must be positive
 */
struct Vector(T, uint N)
if (N > 0)
{
pure:
    /// Alias for Vector element type.
    alias ElementType = T;
    /// Vector dimension.
    enum dimension = N;
    /// Element array.
    T[N] elements = 0;
    alias elements this;

    private ref inout(T) _get(size_t i)() inout
    in { assert(i < N, "Index out of bounds"); }
    do
    {
        return elements[i];
    }
    private ref inout(T[to - from]) _slice(size_t from, size_t to)() inout
    in { assert(from <= N - 1 && to <= N, "Index out of bounds"); }
    do
    {
        return elements[from .. to];
    }

    /// Get a reference to first element.
    alias x = _get!(0);
    alias r = x;  /// ditto
    alias u = x;  /// ditto
    alias s = x;  /// ditto

    static if (N >= 2)
    {
        /// Get a reference to second element.
        alias y = _get!(1);
        alias g = y;  /// ditto
        alias v = y;  /// ditto
        alias t = y;  /// ditto

        /// Get a reference to the first and second elements.
        alias xy = _slice!(0, 2);
        alias rg = xy;  /// ditto
        alias uv = xy;  /// ditto
        alias st = xy;  /// ditto
    }
    static if (N >= 3)
    {
        /// Get a reference to third element.
        alias z = _get!(2);
        alias b = z;  /// ditto
        alias p = z;  /// ditto

        /// Get a reference to the second and third elements.
        alias yz = _slice!(1, 3);
        alias gb = yz;  /// ditto
        alias tp = yz;  /// ditto

        /// Get a reference to the first, second and third elements.
        alias xyz = _slice!(0, 3);
        alias rgb = xyz;  /// ditto
        alias stp = xyz;  /// ditto
    }
    static if (N >= 4)
    {
        /// Get a reference to fourth element.
        alias w = _get!(3);
        alias a = w;  /// ditto
        alias q = w;  /// ditto

        /// Get a reference to the third and fourth elements.
        alias zw = _slice!(2, 4);
        alias ba = zw;  /// ditto
        alias pq = zw;  /// ditto

        /// Get a reference to the second, third and fourth elements.
        alias yzw = _slice!(1, 4);
        alias gba = yzw;  /// ditto
        alias tpq = yzw;  /// ditto

        /// Get a reference to the first, second, third and fourth elements.
        alias xyzw = _slice!(0, 4);
        alias rgba = xyzw;  /// ditto
        alias stpq = xyzw;  /// ditto
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

        Vec4 v2 = [1, 2, 3, 4];
        assert(v2.xy == [1, 2]);
        assert(v2.yz == [2, 3]);
        assert(v2.zw == [3, 4]);
        v2.xyz = 0;
        assert(v2 == [0, 0, 0, 4]);
    }

    /// Constructs a Vector with all elements equal to `scalar`
    this(const T scalar)
    {
        elements[] = scalar;
    }
    unittest
    {
        Vec2 v;
        v = Vec2(1);
        v = Vec2(1.0);
        v = Vec2(1.0f);
    }
    /// Constructs a Vector from static array.
    this()(const auto ref T[N] values)
    {
        elements = values;
    }
    unittest
    {
        Vec2 v;
        v = Vec2([1, 2]);
        v = Vec2([1.0, 2.0]);
        v = Vec2([1.0f, 2.0f]);
    }
    /// Constructs a Vector with elements from an Input Range
    this(R)(auto ref R range)
    if (isInputRange!R)
    {
        auto remainder = range.copy(elements[]);
        remainder[] = 0;
    }
    unittest
    {
        assert(Vec4(iota(4)) == [0, 1, 2, 3]);
        assert(Vec4(iota(8).stride(2)) == [0, 2, 4, 6]);
        assert(Vec4(iota(3)) == [0, 1, 2, 0]);
    }
    /// Constructs a Vector with all elements initialized separetely
    this(Args...)(const auto ref Args args)
    if (args.length <= N)
    {
        this(only(args));
    }
    unittest
    {
        Vec2 v;
        v = Vec2(1, 2);
        v = Vec2(1, 2.0);
        v = Vec2(1.0, 2);
        v = Vec2(1.0, 2.0);
        v = Vec2(1.0f, 2.0f);
    }

    /// Vector with all zeros
    enum Vector zeros = 0;
    alias zeroes = zeros;
    /// Vector with all ones
    enum Vector ones = 1;

    /// Returns a new vector with unary operator applied to all elements
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

    /// Returns a new vector with binary operator applied to all elements and `scalar`
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
    // TODO: shift operations

    /// Ditto
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

    /// Returns a new vector with the results of applying operator against elements of `other`.
    /// If operands dimensions are unequal, copies the values from greater dimension vector.
    Vector!(T, max(N, M)) opBinary(string op, uint M)(const auto ref T[M] other) const
    if (op != "~")
    {
        enum minDimension = min(N, M);
        typeof(return) result;
        mixin(q{result[0 .. minDimension] = elements[0 .. minDimension]} ~ op ~ q{other[0 .. minDimension];});
        static if (M < N)
        {
            result[minDimension .. N] = elements[minDimension .. N];
        }
        else static if (N < M)
        {
            result[minDimension .. M] = other[minDimension .. M];
        }
        return result;
    }
    unittest
    {
        assert(Vec2(1, 2) + Vec2(3, 4) == [1f+3f, 2f+4f]);
        assert(Vec2(1, 2) - Vec2(3, 4) == [1f-3f, 2f-4f]);
        assert(Vec2(1, 2) * Vec2(3, 4) == [1f*3f, 2f*4f]);
        assert(Vec2(1, 2) / Vec2(3, 4) == [1f/3f, 2f/4f]);
        assert(__traits(compiles, Vec2(1, 2) + [3, 4]));

        assert(Vec2(1, 2) + Vec1(3) == [1f+3f, 2f]);
        assert(Vec2(1, 2) - Vec1(3) == [1f-3f, 2f]);
        assert(Vec2(1, 2) * Vec1(3) == [1f*3f, 2f]);
        assert(Vec2(1, 2) / Vec1(3) == [1f/3f, 2f]);

        assert(Vec2(1, 2) + Vec3(3, 4, 5) == [1f+3f, 2f+4f, 5f]);
        assert(Vec2(1, 2) - Vec3(3, 4, 5) == [1f-3f, 2f-4f, 5f]);
        assert(Vec2(1, 2) * Vec3(3, 4, 5) == [1f*3f, 2f*4f, 5f]);
        assert(Vec2(1, 2) / Vec3(3, 4, 5) == [1f/3f, 2f/4f, 5f]);
    }

    /// Returns a new vector of greater dimension by copying elements and appending `scalar`.
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
    /// Returns a new vector of greater dimension by copying elements and prepending `scalar`.
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

    /// Returns a new vector of greater dimension by copying elements and appending values from `other`.
    Vector!(T, N + M) opBinary(string op : "~", M)(const auto ref T[M] other) const
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
    /// Returns a new vector of greater dimension by copying elements and prepending values from `other`.
    Vector!(T, N + M) opBinaryRight(string op : "~", M)(const auto ref T[M] other) const
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

    /// Cast to a static array of same dimension, but different element type.
    U opCast(U : T2[N], T2)() const
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
        auto floatVec = cast(Vec2) intVec;
        assert(floatVec == Vec2(1f, 2f));
        assert(cast(Vec2i) floatVec == intVec);

        auto floatArray = cast(float[2]) intVec;
        assert(floatArray == [1f, 2f]);
    }

    /// Assign result of applying operator with `scalar` to elements.
    ref Vector opOpAssign(string op)(const T scalar) return
    {
        mixin(q{elements[] } ~ op ~ q{= scalar;});
        return this;
    }
    unittest
    {
        Vec2 v = [1, 2];
        v += 5;
        assert(v == [6, 7]);
    }
    /// Assign result of applying operator with `other` to elements.
    ref Vector opOpAssign(string op, uint M)(const auto ref T[M] other) return
    {
        enum minDimension = min(N, M);
        mixin(q{elements[0 .. minDimension] } ~ op ~ q{= other[0 .. minDimension];});
        return this;
    }
    unittest
    {
        Vec3 v = [1, 2, 3];
        v += Vec2(1, 2);
        assert(v == [2, 4, 3]);

        v += Vec4(1, 2, 3, 4);
        assert(v == [3, 6, 6]);
    }

    unittest
    {
        assert(Vec2.sizeof == Vec2.elements.sizeof);
        assert(Vec3.sizeof == Vec3.elements.sizeof);
        assert(Vec4.sizeof == Vec4.elements.sizeof);

        alias Vec2_100 = Vec2[100];
        assert(Vec2_100.sizeof == 100 * Vec2.elements.sizeof);

        auto v = Vec2(5);
        v += 3;
        assert(v == Vec2(8));
    }
}

/// True if `T` is some kind of Vector
enum isVector(T) = is(T : Vector!U, U...);

/// Construct Vector directly from static array, inferring element type.
Vector!(T, N) vector(T, uint N)(const auto ref T[N] elements)
{
    return typeof(return)(elements);
}
unittest
{
    auto v = [1, 2, 3].vector;
    assert(v.elements == [1, 2, 3]);
    assert(is(typeof(v) == Vector!(int, 3)));
}

/// Returns the dot product between two Vectors.
pure T dot(T, uint N)(const auto ref Vector!(T, N) a, const auto ref Vector!(T, N) b)
{
    auto multiplied = a * b;
    return multiplied[].sum;
}

/// Returns the cross product between two 3D Vectors.
pure Vector!(T, 3) cross(T)(const auto ref Vector!(T, 3) a, const auto ref Vector!(T, 3) b)
{
    typeof(return) result = [
        a.y * b.z - a.z * b.y,
        a.z * b.x - a.x * b.z,
        a.x * b.y - a.y * b.x,
    ];
    return result;
}

/// Returns a Vector that is the reflection of `vec` against `normal`.
pure Vector!(T, N) reflect(T, uint N)(const auto ref Vector!(T, N) vec, const auto ref Vector!(T, N) normal)
{
    return vec - (2 * normal * dot(vec, normal));
}

/// Returns the squared magnitude (Euclidean length) of a Vector.
pure T magnitudeSquared(T, uint N)(const auto ref Vector!(T, N) vec)
out (r) { assert(r >= 0, "Vector squared magnitude should be non-negative!"); }
do
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

/// Returns the magnitude (Euclidean length) of a Vector.
auto magnitude(T, uint N)(const auto ref Vector!(T, N) vec)
out (r) { assert(r >= 0, "Vector magnitude should be non-negative!"); }
do
{
    return sqrt(vec.magnitudeSquared());
}
unittest
{
    assert(Vec2(0, 0).magnitude() == 0);
    assert(Vec2(1, 0).magnitude() == 1);
    assert(Vec2(0, 1).magnitude() == 1);
    assert(Vec2(1, 1).magnitude() == sqrt(2f));
    assert(Vec2(2, 0).magnitude() == 2);
}

Vector!(typeof(mapfunc(cast(T) 0)), N) map(alias mapfunc, T, uint N)(const auto ref Vector!(T, N) vec)
{
    typeof(return) result;
    foreach (i; 0 .. N)
    {
        result[i] = mapfunc(vec[i]);
    }
    return result;
}
unittest
{
    Vec3 v = [-1, 2.5, -3];
    import std.math : abs, floor;
    assert(v.map!(abs) == Vec3(1, 2.5, 3));
    assert(v.map!(floor) == Vec3(-1, 2, -3));
    assert(v.map!(x => x + 1) == Vec3(-1 + 1, 2.5 + 1, -3 + 1));
}

/// Normalize a Vector inplace.
ref Vector!(T, N) normalize(T, uint N)(ref return Vector!(T, N) vec)
{
    auto sqMag = vec.magnitudeSquared();
    if (sqMag != 0)
    {
        enum FloatType!T one = 1;
        const auto inverseMag = one / sqrt(sqMag);
        vec *= inverseMag;
    }
    return vec;
}
unittest
{
    Vec2 v = [5, 0];
    v.normalize();
    assert(v == Vec2(1, 0));
}

/// Returns a normalized copy of Vector.
Vector!(T, N) normalized(T, uint N)(const auto ref Vector!(T, N) vec)
{
    typeof(return) copy = vec;
    return copy.normalize();
}
unittest
{
    Vec2 v = [200, 0];
    assert(v.normalized() == Vec2(1, 0));
    assert(v == Vec2(200, 0));
}

unittest
{
    Vec2 a = [1, 1];
    Vec2 b = [2, 3];
    assert(lerp(a, b, 0) == a);
    assert(lerp(a, b, 0.5) == Vec2(1.5, 2));
    assert(lerp(a, b, 1) == b);
}
