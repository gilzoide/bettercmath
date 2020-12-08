module bettercmath.matrix;

import std.math : PI;
import std.traits : isFloatingPoint;

import bettercmath.vector;

@safe @nogc pure nothrow:

version (unittest)
{
    private alias Vec2 = Vector!(float, 2);
    private alias Vec3 = Vector!(float, 3);
    private alias Mat2 = Matrix!(float, 2);
    private alias Mat23 = Matrix!(float, 2, 3);
    private alias Mat32 = Matrix!(float, 3, 2);
    private alias Mat3 = Matrix!(float, 3);
    private alias Mat34 = Matrix!(float, 3, 4);
    private alias Mat43 = Matrix!(float, 4, 3);
    private alias Mat4 = Matrix!(float, 4);
}

struct Matrix(T, uint _numColumns, uint _numRows = _numColumns)
if (_numColumns > 0 && _numRows > 0)
{
    import std.algorithm : min;
    enum numColumns = _numColumns;
    enum numRows = _numRows;
    enum minDimension = min(numColumns, numRows);
    enum numElements = numColumns * numRows;
    enum isSquare = numColumns == numRows;
    alias RowVector = T[numColumns];
    alias ColumnVector = T[numRows];

    T[numElements] elements = 0;
    alias elements this;
    
    inout(T)[] opIndex(size_t i) inout
    in { assert(i < numColumns); }
    do
    {
        auto initialIndex = i * numRows;
        return elements[initialIndex .. initialIndex + numRows];
    }
    ref inout(T) opIndex(size_t i, size_t j) inout
    in { assert(i < numColumns && j < numRows); }
    do
    {
        return elements[i*numRows + j];
    }

    @property size_t opDollar(size_t pos : 0)()
    {
        return numColumns;
    }
    @property size_t opDollar(size_t pos : 1)()
    {
        return numRows;
    }

    static Matrix fromColumns(Args...)(const Args args)
    if (args.length == numElements)
    {
        Matrix mat = {
            elements: [args],
        };
        return mat;
    }
    static Matrix fromColumns(const T[numElements] elements)
    {
        Matrix mat = {
            elements: elements,
        };
        return mat;
    }
    static Matrix fromColumns(const T[numColumns][numRows] columns)
    {
        Matrix mat = {
            elements: cast(T[numElements]) columns,
        };
        return mat;
    }

    static Matrix fromRows(Args...)(const Args args)
    {
        return Matrix!(T, numRows, numColumns).fromColumns(args).transposed;
    }

    static Matrix fromDiagonal(const T diag)
    {
        Matrix mat;
        foreach (i; 0 .. minDimension)
        {
            mat[i, i] = diag;
        }
        return mat;
    }
    static Matrix fromDiagonal(uint N)(const Vector!(T, N) diag)
    if (N <= minDimension)
    {
        Matrix mat;
        foreach (i; 0 .. N)
        {
            mat[i, i] = diag[i];
        }
        return mat;
    }

    ColumnVector opBinary(string op : "*")(const RowVector vec) const
    {
        typeof(return) result = void;
        foreach (i; 0 .. numRows)
        {
            T sum = 0;
            foreach (j; 0 .. numColumns)
            {
                sum += this[j, i] * vec[j];
            }
            result[i] = sum;
        }
        return result;
    }
    unittest
    {
        auto m1 = Mat23.fromRows(1, 2,
                                 3, 4,
                                 5, 6);
        auto v1 = Vec2(1, 2);
        assert(m1 * v1 == Vec3(1*1 + 2*2,
                               1*3 + 2*4,
                               1*5 + 2*6));
    }

    Matrix!(T, OtherColumns, numRows) opBinary(string op : "*", uint OtherColumns)(const Matrix!(T, OtherColumns, numColumns) other) const
    {
        typeof(return) result = void;
        foreach (i; 0 .. numRows)
        {
            foreach (j; 0 .. OtherColumns)
            {
                T sum = 0;
                foreach (k; 0 .. numColumns)
                {
                    sum += this[k, i] * other[j, k];
                }
                result[j, i] = sum;
            }
        }
        return result;
    }
    unittest
    {
        alias Mat23 = Matrix!(int, 2, 3);
        alias Mat12 = Matrix!(int, 1, 2);

        Mat23 m1 = Mat23.fromRows(1, 1,
                                  2, 2,
                                  3, 3);
        Mat12 m2 = Mat12.fromRows(4,
                                  5);
        auto result = m1 * m2;
        assert(result == [1*4 + 1*5,
                          2*4 + 2*5,
                          3*4 + 3*5]);
    }

    static if (isSquare)
    {
        static Matrix makeIdentity()
        {
            return fromDiagonal(1);
        }
        enum identity = makeIdentity();

        ref Matrix opOpAssign(string op : "*")(const Matrix other)
        {
            foreach (i; 0 .. numRows)
            {
                foreach (j; 0 .. numColumns)
                {
                    T sum = 0;
                    foreach (k; 0 .. numColumns)
                    {
                        sum += this[k, i] * other[j, k];
                    }
                    this[j, i] = sum;
                }
            }
            return this;
        }
    }


    // Matrix 4x4 methods
    static if (numColumns == 4 && numRows == 4)
    {
        static Matrix orthographic(T left, T right, T bottom, T top, T near = -1, T far = 1)
        {
            // See https://www.khronos.org/registry/OpenGL-Refpages/gl2.1/xhtml/glOrtho.xml
            Matrix result;

            result[0, 0] = 2.0 / (right - left);
            result[1, 1] = 2.0 / (top - bottom);
            result[2, 2] = 2.0 / (near - far);
            result[3, 3] = 1.0;

            result[3, 0] = (left + right) / (left - right);
            result[3, 1] = (bottom + top) / (bottom - top);
            result[3, 2] = (far + near) / (near - far);

            return result;
        }
        alias ortho = orthographic;

        static Matrix perspective(T fov, T aspectRatio, T near, T far)
        {
            // See https://www.khronos.org/registry/OpenGL-Refpages/gl2.1/xhtml/gluPerspective.xml
            Matrix result;

            import bettercmath.cmath : tan;
            T cotangent = 1.0 / tan(fov * (PI / 360.0));

            result[0, 0] = cotangent / aspectRatio;
            result[1, 1] = cotangent;
            result[2, 3] = -1.0;
            result[2, 2] = (near + far) / (near - far);
            result[3, 2] = (2.0 * near * far) / (near - far);
            result[3, 3] = 0.0;

            return result;
        }
    }
}

enum isMatrix(T) = is(T : Matrix!U, U...);

ref Matrix!(T, C, C) transpose(T, uint C)(ref return Matrix!(T, C, C) mat)
{
    import std.algorithm : swap;
    foreach (i; 0 .. C)
    {
        foreach (j; i+1 .. C)
        {
            swap(mat[j, i], mat[i, j]);
        }
    }
    return mat;
}
unittest
{
    auto m1 = Mat2.fromRows(1, 2,
                            3, 4);
    transpose(m1);
    assert(m1 == Mat2.fromRows(1, 3,
                               2, 4));
}

Matrix!(T, R, C) transposed(T, uint C, uint R)(const Matrix!(T, C, R) mat)
{
    typeof(return) newMat = void;
    foreach (i; 0 .. R)
    {
        foreach (j; 0 .. C)
        {
            newMat[i, j] = mat[j, i];
        }
    }
    return newMat;
}
unittest
{
    float[6] elements = [1, 2, 3, 4, 5, 6];
    float[6] transposedElements = [1, 4, 2, 5, 3, 6];
    auto m1 = Mat23.fromColumns(elements);
    auto m2 = transposed(m1);
    assert(m2 == transposedElements);
    assert(transposed(m1.transposed) == m1);
}

