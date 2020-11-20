import std.math;

@safe @nogc pure nothrow:

/++
 + TODO: doc
 +/
struct Vector(T, int N)
{
    /// Element holder
    T[N] elements = 0;
    alias elements this;

    ref inout(T) get_(int i)() inout
    in(i >= 0 && i <= N, "Index out of bounds")
    {
        return elements[i];
    }
    ref inout(T[to - from]) get_(int from, int to)() inout
    in(from >= 0 && to <= N, "Index out of bounds")
    {
        return elements[from .. to];
    }

    alias x = get_!(0);
    alias r = x;
    alias u = x;
    alias s = x;

    alias y = get_!(1);
    alias g = y;
    alias v = y;
    alias t = y;

    static if (N > 2)
    {
        alias z = get_!(2);
        alias b = z;
        alias p = z;

        alias xy = get_!(0, 2);
        alias rg = xy;
        alias uv = xy;
        alias st = xy;

        alias yz = get_!(1, 3);
        alias gb = yz;
        alias tp = yz;
    }
    static if (N > 3)
    {
        alias w = get_!(3);
        alias a = w;
        alias q = w;

        alias zw = get_!(2, 4);
        alias ba = zw;
        alias pq = zw;

        alias xyz = get_!(0, 3);
        alias rgb = xyz;
        alias stp = xyz;

        alias yzw = get_!(1, 4);
        alias gba = yzw;
        alias tpq = yzw;
    }

    unittest
    {
        alias Vec4 = Vector!(float, 4);
        Vec4 a = {[1, 2, 3, 4]};
        Vec4 b = {[1, 2, 3, 4]};
        assert(a == b);
        assert(a.elements == b.elements);
        assert(a.xy == b.xy);
    }

    // Operators
    private alias Self = typeof(this);

    Self opUnary(string op)() const
    {
        Self result;
        mixin(q{result =} ~ op ~ q{elements[];});
        return result;
    }

    Self opBinary(string op)(immutable T scalar) const
    {
        Self result;
        mixin(q{result = elements[]} ~ op ~ q{scalar;});
        return result;
    }
    Self opBinary(string op)(immutable Self other) const
    {
        Self result;
        mixin(q{result = elements[]} ~ op ~ q{other.elements[];});
        return result;
    }

    Self opOpAssign(string op)(immutable T scalar)
    {
        mixin(q{elements = elements[]} ~ op ~ q{scalar;});
        return this;
    }
    Self opOpAssign(string op)(immutable Self other)
    {
        mixin(q{elements = elements[]} ~ op ~ q{other[];});
        return this;
    }

    unittest
    {
        alias Vec4 = Vector!(float, 4);
        Vec4 a = {[1, 2, 3, 4]};
        assert(a + a - a == a);
        immutable Vec4 b = {[2, 3, 4, 5]};
        assert(a + 1 == b);
        assert(b - 1 == a);
        Vec4 c = {[-1, -2, -3, -4]};
        assert(-a == c);
        c = a += 1;
        assert(a == b);
        assert(a == c);
    }
}
