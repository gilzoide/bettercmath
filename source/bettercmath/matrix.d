module bettercmath.matrix;

import std.math : PI;
import std.traits : isFloatingPoint;

import bettercmath.vector;

@safe @nogc pure nothrow:

version (unittest)
{
    private alias Vec2 = Vector!(float, 2);
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

    Matrix!(T, numRows, numColumns) transposed() const
    {
        typeof(return) newMat = void;
        foreach (i; 0..numRows)
        {
            foreach (j; 0..numColumns)
            {
                newMat[i, j] = this[j, i];
            }
        }
        return newMat;
    }
    unittest
    {
        import std.traits : ReturnType;
        assert(is(ReturnType!(Mat23.transposed) == Mat32));
        assert(is(ReturnType!(Mat32.transposed) == Mat23));
        float[6] elements = [1, 2, 3, 4, 5, 6];
        float[6] transposedElements = [1, 4, 2, 5, 3, 6];
        auto m1 = Mat23.fromColumns(elements);
        auto m2 = m1.transposed;
        assert(m2 == transposedElements);
        assert(m1.transposed.transposed == m1);
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


    static if (isSquare)
    {
        static Matrix makeIdentity()
        {
            return fromDiagonal(1);
        }
        enum identity = makeIdentity();

        ref Matrix transpose()
        {
            import std.algorithm : swap;
            foreach (i; 0..numRows)
            {
                foreach (j; 0..numColumns)
                {
                    swap(this[j, i], this[i, j]);
                }
            }
            return this;
        }
    }

    ColumnVector opBinary(string op : "*")(const RowVector vec)
    {
        ColumnVector result = void;
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

unittest
{
    Mat2 m = Mat2.fromColumns(1, 2, 3, 4);
    Vec2 v = [2, 3];
    float[2] result = [1*2 + 3*3, 2*2 + 4*3];
    assert(m * v == result);

    float[4][4] cols;
    float[16] v2 = cast(float[16]) cols;
    float[4][4] v3 = cast(float[4][4]) v2;
}
