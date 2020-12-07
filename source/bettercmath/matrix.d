module bettercmath.matrix;

import std.math : PI;
import std.traits : isFloatingPoint;

@safe @nogc pure nothrow:

version (unittest)
{
    import bettercmath.vector;
    private alias Vec2 = Vector!(float, 2);
    private alias Mat2 = Matrix!(float, 2);
    private alias Mat3 = Matrix!(float, 3);
    private alias Mat34 = Matrix!(float, 3, 4);
    private alias Mat4 = Matrix!(float, 4);
}

struct Matrix(T, uint _numColumns, uint _numRows = _numColumns)
if (isFloatingPoint!T && _numColumns > 0 && _numRows > 0)
{
    enum numColumns = _numColumns;
    enum numRows = _numRows;
    enum numElements = numColumns * numRows;
    enum isSquare = numColumns == numRows;
    alias RowVector = T[numColumns];
    alias ColumnVector = T[numRows];

    T[numElements] elements = 0;
    
    @property ref inout(T)[numRows][numColumns] columns() inout
    {
        return cast(typeof(return)) elements[];
    }
    alias columns this;

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
        return fromColumns(args).transposed;
    }

    Matrix!(T, numRows, numColumns) transposed()
    {
        typeof(return) newMat = void;
        foreach (i; 0..numRows)
        {
            foreach (j; 0..numColumns)
            {
                newMat.elements[j*numRows + i] = elements[i*numColumns + j];
            }
        }
        return newMat;
    }

    static if (isSquare)
    {
        static Matrix identity()
        {
            Matrix mat = zeros;
            foreach (i; 0..numColumns)
            {
                mat[i][i] = 1;
            }
            return mat;
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
                sum += columns[j][i] * vec[j];
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

            result.columns[0][0] = 2.0 / (right - left);
            result.columns[1][1] = 2.0 / (top - bottom);
            result.columns[2][2] = 2.0 / (near - far);
            result.columns[3][3] = 1.0;

            result.columns[3][0] = (left + right) / (left - right);
            result.columns[3][1] = (bottom + top) / (bottom - top);
            result.columns[3][2] = (far + near) / (near - far);

            return result;
        }
        alias ortho = orthographic;

        static Matrix perspective(T fov, T aspectRatio, T near, T far)
        {
            // See https://www.khronos.org/registry/OpenGL-Refpages/gl2.1/xhtml/gluPerspective.xml
            Matrix result;

            import bettercmath.cmath : tan;
            T cotangent = 1.0 / tan(fov * (PI / 360.0));

            result.columns[0][0] = cotangent / aspectRatio;
            result.columns[1][1] = cotangent;
            result.columns[2][3] = -1.0;
            result.columns[2][2] = (near + far) / (near - far);
            result.columns[3][2] = (2.0 * near * far) / (near - far);
            result.columns[3][3] = 0.0;

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
