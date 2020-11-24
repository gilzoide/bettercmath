module bettercmath.matrix;

import bettercmath.cmath;
import bettercmath.vector;
import std.math : PI;
import std.traits;

version (unittest)
{
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
    alias RowVector = Vector!(T, numColumns);
    alias ColumnVector = Vector!(T, numRows);

    union
    {
        ColumnVector[numColumns] columns;
        T[numColumns * numRows] elements;
    }
    alias columns this;

    static Matrix fromColumns(Args...)(const Args args)
    {
        Matrix mat;
        mat.elements = [args];
        return mat;
    }
    static Matrix fromColumns(const T[numColumns * numRows] elements)
    {
        Matrix mat;
        mat.elements = elements;
        return mat;
    }
    static Matrix fromColumns(const T[numColumns][numRows] columns)
    {
        Matrix mat;
        mat.columns = cast(ColumnVector[numColumns]) columns;
        return mat;
    }

    static Matrix fromRows(Args...)(const Args args)
    if (args.length == numRows * numColumns)
    {
        Matrix mat;
        static foreach (i; 0 .. numRows)
        {
            static foreach (j; 0 .. numColumns)
            {
                mat.columns[j][i] = args[i*numColumns + j];
            }
        }
        return mat;
    }
    static Matrix fromRows(const T[numRows][numColumns] rows)
    {
        Matrix mat;
        foreach (i; 0 .. numRows)
        {
            foreach (j; 0 .. numColumns)
            {
                mat.columns[j][i] = rows[i][j];
            }
        }
        return mat;
    }
    static Matrix fromRows(const T[numRows * numColumns] elements)
    {
        Matrix mat;
        foreach (i; 0 .. numRows)
        {
            foreach (j; 0 .. numColumns)
            {
                mat.columns[j][i] = elements[i*numColumns + j];
            }
        }
        return mat;
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

unittest
{
    Mat2 m = Mat2.fromColumns(1, 2, 3, 4);
    Vec2 v = [2, 3];
    assert(m * v == [1*2 + 3*3, 2*2 + 4*3]);
}
