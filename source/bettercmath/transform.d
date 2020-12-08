module bettercmath.transform;

import bettercmath.matrix;
import bettercmath.vector;

struct Transform(T, uint Dim, bool compact = false)
if (Dim > 0)
{
    static if (!compact)
    {
        alias MatrixType = Matrix!(T, Dim + 1, Dim + 1);
    }
    else
    {
        alias MatrixType = Matrix!(T, Dim + 1, Dim);
    }
    alias VectorType = Vector!(T, Dim);

    MatrixType matrix = MatrixType.fromDiagonal(1);
    alias matrix this;

    enum identity = Transform.init;

    this(const MatrixType matrix)
    {
        this.matrix = matrix;
    }

    static Transform fromTranslation(uint N)(const Vector!(T, N) values)
    if (N <= Dim)
    {
        Transform t;
        t[$-1][0 .. values.length] = values[];
        return t;
    }
    ref Transform translate(uint N)(const Vector!(T, N) values)
    if (N <= Dim)
    {
        this[$-1][0 .. values.length] += values[];
        return this;
    }
    Transform translated(uint N)(const Vector!(T, N) values) const
    if (N <= Dim)
    {
        Transform t = this;
        t.translate(values);
        return t;
    }

    static Transform fromScaling(uint N)(const Vector!(T, N) values)
    if (N <= Dim)
    {
        Transform t;
        t.scale(values);
        return t;
    }
    ref Transform scale(uint N)(const Vector!(T, N) values)
    if (N <= Dim)
    {
        foreach (i; 0 .. N)
        {
            this[i, i] *= values[i];
        }
        return this;
    }
    Transform scaled(uint N)(const Vector!(T, N) values) const
    {
        Transform t = this;
        t.scale(values);
        return t;
    }

    static Transform fromShearing(uint N)(const Vector!(T, N) values)
    if (N <= Dim)
    {
        Transform t;
        t.shear(values);
        return t;
    }
    ref Transform shear(uint N)(const Vector!(T, N) values)
    if (N <= Dim)
    {
        foreach (i; 0 .. N)
        {
            foreach (j; 0 .. N)
            {
                if (j != i)
                {
                    this[j, i] = values[i];
                }
            }
        }
        return this;
    }
    Transform sheared(uint N)(const Vector!(T, N) values) const
    if (N <= Dim)
    {
        Transform t = this;
        t.shear(values);
        return t;
    }
}

unittest
{
    alias Transform2D = Transform!(float, 2);
    alias Transform2DCompact = Transform!(float, 2, true);
    alias Transform3D = Transform!(float, 3);
    alias Transform3DCompact = Transform!(float, 3, true);
}
