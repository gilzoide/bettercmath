module bettercmath.vector;

import std.math;

@safe @nogc pure nothrow:

/++
 + TODO: doc
 +/
struct Vector(T, uint N)
if (N > 1)
{
    private alias Self = typeof(this);
    version (unittest)
    {
        private alias Vec2 = Vector!(float, 2);
        private alias Vec3 = Vector!(float, 3);
        private alias Vec4 = Vector!(float, 4);
    }

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

    this(const T scalar)
    {
        elements[] = scalar;
    }
    this(Args...)(const Args args)
    if (args.length == N)
    {
        elements = [args];
    }
    this(const T[N] values)
    {
        elements[] = values[];
    }

    static Self zeros()
    {
        Self result = 0;
        return result;
    }
    alias zeroes = zeros;

    static Self ones()
    {
        Self result = 1;
        return result;
    }

    // Operators
    Self opUnary(string op)() const
    {
        Self result;
        mixin(q{result =} ~ op ~ q{elements[];});
        return result;
    }

    Self opBinary(string op)(const T scalar) const
    {
        Self result;
        mixin(q{result = elements[]} ~ op ~ q{scalar;});
        return result;
    }
    Self opBinary(string op)(const Self other) const
    {
        Self result;
        mixin(q{result = elements[]} ~ op ~ q{other.elements[];});
        return result;
    }
    Vector!(T, N + 1) opBinary(string op : "~")(const T scalar) const
    {
        typeof(return) result;
        result[0 .. N] = elements[];
        result[N] = scalar;
        return result;
    }
    Vector!(T, N + 1) opRightBinary(string op : "~")(const T scalar) const
    {
        typeof(return) result;
        result[0] = scalar;
        result[1 .. N = 1] = elements[];
        return result;
    }

    Self opOpAssign(string op)(const T scalar)
    {
        mixin(q{elements = elements[]} ~ op ~ q{scalar;});
        return this;
    }
    Self opOpAssign(string op)(const Self other)
    {
        mixin(q{elements = elements[]} ~ op ~ q{other[];});
        return this;
    }
}

unittest
{
    alias Vec4 = Vector!(float, 4);
    Vec4 a = [1, 2, 3, 4];
    Vec4 b = [1, 2, 3, 4];
    assert(a == b);
    assert(a.elements == b.elements);
    assert(a.xy == b.xy);
}

unittest
{
    alias Vec4 = Vector!(float, 4);
    Vec4 a = [1f, 2f, 3f, 4f];
    assert(a + a - a == a);
    immutable Vec4 b = [2, 3, 4, 5];
    assert(a + 1 == b);
    assert(b - 1 == a);
    Vec4 c = [-1, -2, -3, -4];
    assert(-a == c);
    c = a += 1;
    assert(a == b);
    assert(a == c);
}
