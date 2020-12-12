module bettercmath.transform;

import bettercmath.cmath : cos, sin;
import bettercmath.matrix;
import bettercmath.misc : FloatType;
import bettercmath.vector;

@nogc @safe pure nothrow:

struct Transform(T, uint Dim, bool compact = false)
if (Dim > 0)
{
    static if (!compact)
    {
        alias MatrixType = Matrix!(T, Dim + 1, Dim + 1);
        alias CompactTransform = Transform!(T, Dim, true);
        alias FullTransform = typeof(this);

        ref CompactTransform.MatrixType compactInto(ref return CompactTransform.MatrixType mat) inout
        {
            foreach (i; 0 .. Dim + 1)
            {
                mat[i][0 .. Dim] = this.matrix[i][0 .. Dim];
            }
            return mat;
        }

        CompactTransform compact() const
        {
            typeof(return) t = void;
            compactInto(t.matrix);
            return t;
        }

        static bool isAffineTransformMatrix(const MatrixType matrix)
        {
            import std.algorithm : equal;
            import std.range : chain, only, repeat;
            return matrix.rows[Dim].equal(repeat(Dim, 0).chain(only(1)));
        }

        auto opCast(U : CompactTransform)() const
        {
            return compact();
        }
    }
    else
    {
        alias MatrixType = Matrix!(T, Dim + 1, Dim);
        alias CompactTransform = typeof(this);
        alias FullTransform = Transform!(T, Dim, false);
        
        ref FullTransform.MatrixType fullInto(ref return FullTransform.MatrixType mat) inout
        {
            foreach (i; 0 .. Dim + 1)
            {
                mat[i][0 .. Dim] = this.matrix[i][0 .. Dim];
                mat[i][Dim] = 0;
            }
            mat[Dim][Dim] = 1;
            return mat;
        }

        FullTransform full() const
        {
            typeof(return) t = void;
            fullInto(t.matrix);
            return t;
        }

        static bool isAffineTransformMatrix(const MatrixType matrix)
        {
            return true;
        }

        auto opCast(U : FullTransform)() const
        {
            return full();
        }
    }
    alias FT = FloatType!T;

    MatrixType matrix = MatrixType.fromDiagonal(1);
    alias matrix this;

    enum identity = Transform.init;

    this(const MatrixType matrix)
    in { assert(isAffineTransformMatrix(matrix), "Matrix is not suitable for affine transformations"); }
    do
    {
        this.matrix = matrix;
    }

    static Transform fromTranslation(uint N)(const Vector!(T, N) values)
    if (N <= Dim)
    {
        Transform t;
        t[$-1][0 .. N] = values[];
        return t;
    }
    ref Transform translate(uint N)(const Vector!(T, N) values)
    if (N <= Dim)
    {
        this[$-1][0 .. N] += values[];
        return this;
    }
    Transform translated(uint N)(const Vector!(T, N) values) const
    if (N <= Dim)
    {
        Transform t = this;
        return t.translate(values);
    }

    static Transform fromScaling(uint N)(const Vector!(T, N) values)
    if (N <= Dim)
    {
        Transform t;
        foreach (i; 0 .. N)
        {
            t[i, i] = values[i];
        }
        return t;
    }
    ref Transform scale(uint N)(const Vector!(T, N) values)
    if (N <= Dim)
    {
        return this.combine(CompactTransform.fromScaling(values));
    }
    Transform scaled(uint N)(const Vector!(T, N) values) const
    {
        Transform t = this;
        return t.scale(values);
    }

    static Transform fromShearing(uint N)(const Vector!(T, N) values)
    if (N <= Dim)
    {
        Transform t;
        foreach (i; 0 .. N)
        {
            foreach (j; 0 .. N)
            {
                if (j != i)
                {
                    t[j, i] = values[i];
                }
            }
        }
        return t;
    }
    ref Transform shear(uint N)(const Vector!(T, N) values)
    if (N <= Dim)
    {
        return this.combine(CompactTransform.fromShearing(values));
    }
    Transform sheared(uint N)(const Vector!(T, N) values) const
    if (N <= Dim)
    {
        Transform t = this;
        return t.shear(values);
    }

    // 2D transforms
    static if (Dim >= 2)
    {
        static Transform fromRotation(const FT angle)
        {
            Transform t;
            const auto c = cos(angle), s = sin(angle);
            t[0, 0] = c; t[0, 1] = -s;
            t[1, 0] = s; t[1, 1] = c;
            return t;
        }
        ref Transform rotate(const FT angle)
        {
            return this.combine(CompactTransform.fromRotation(angle));
        }
        Transform rotated(const FT angle) const
        {
            Transform t = this;
            return t.rotate(angle);
        }
    }
    // 3D transforms
    else static if (Dim >= 3)
    {
        static Transform fromXRotation(const FT angle)
        {
            Transform t;
            auto c = cos(angle), s = sin(angle);
            t[1, 1] = c; t[2, 1] = -s;
            t[1, 2] = s; t[2, 2] = c;
            return t;
        }
        ref Transform rotateX(const FT angle)
        {
            return this.combine(CompactTransform.fromXRotation(angle));
        }
        Transform rotatedX(const FT angle) const
        {
            Transform t = this;
            return t.rotateX(angle);
        }

        static Transform fromYRotation(const FT angle)
        {
            Transform t;
            auto c = cos(angle), s = sin(angle);
            t[0, 0] = c; t[2, 0] = s;
            t[0, 2] = -s; t[2, 2] = c;
            return t;
        }
        ref Transform rotateY(const FT angle)
        {
            return this.combine(CompactTransform.fromYRotation(angle));
        }
        Transform rotatedY(const FT angle) const
        {
            Transform t = this;
            return t.rotateY(angle);
        }

        // Rotating in Z is the same as rotating in 2D
        static Transform fromZRotation(const FT angle)
        {
            return fromRotation(angle);
        }
        ref Transform rotateZ(const FT angle)
        {
            return rotate(angle);
        }
        Transform rotatedY(const FT angle) const
        {
            return rotated(angle);
        }
    }
}

/// Pre-multiply transformation into target, returning a reference to target
ref Transform!(T, Dim, C1) combine(T, uint Dim, bool C1, bool C2)(ref return Transform!(T, Dim, C1) target, const Transform!(T, Dim, C2) transformation)
{
    target = target.combined(transformation);
    return target;
}
/// Returns the result of pre-multiplying transformation and target
Transform!(T, Dim, C1) combined(T, uint Dim, bool C1, bool C2)(const Transform!(T, Dim, C1) target, const Transform!(T, Dim, C2) transformation)
{
    // Just about matrix multiplication, but assuming last row is [0...0 1]
    typeof(return) result;
    foreach (i; 0 .. Dim)
    {
        foreach (j; 0 .. Dim + 1)
        {
            T sum = 0;
            foreach (k; 0 .. Dim)
            {
                sum += transformation[k, i] * target[j, k];
            }
            result[j, i] = sum;
        }
        // Last column has to take input's last row's 1
        result[Dim, i] += transformation[Dim, i];
    }
    return result;
}

unittest
{
    alias Transform2D = Transform!(float, 2);
    alias Transform2DCompact = Transform!(float, 2, true);
    alias Transform3D = Transform!(float, 3);
    alias Transform3DCompact = Transform!(float, 3, true);
}
