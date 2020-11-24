module bettercmath.matrix;

import bettercmath.cmath;
import bettercmath.vector;
import std.math : PI;
import std.traits;

version (unittest)
{
    private alias Mat4 = Matrix!(float, 4);
}

struct Matrix(T, uint _numColumns, uint _numRows = _numColumns)
if (isFloatingPoint!T && _numColumns > 0 && _numRows > 0)
{
    private alias Self = typeof(this);

    enum numColumns = _numColumns;
    enum numRows = _numRows;
    alias RowVector = Vector!(T, numColumns);
    alias ColumnVector = Vector!(T, numRows);

    union
    {
        ColumnVector[numRows] columns;
        T[numColumns * numRows] elements;
    }
    alias columns this;

    this(const Vector!(T, numColumns)[numRows] columns)
    {
        this.columns = columns;
    }

    this(const T[numColumns * numRows] elements)
    {
        this.elements = elements;
    }

    this(Args...)(const Args args)
    if (args.length == numColumns * numRows)
    {
        elements = [args];
    }

    ColumnVector opBinary(string op : "*")(RowVector vec)
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
        static Self orthographic(T left, T right, T bottom, T top, T near = -1, T far = 1)
        {
            // See https://www.khronos.org/registry/OpenGL-Refpages/gl2.1/xhtml/glOrtho.xml
            Self result;

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

        static Self perspective(T fov, T aspectRatio, T near, T far)
        {
            // See https://www.khronos.org/registry/OpenGL-Refpages/gl2.1/xhtml/gluPerspective.xml
            Self result;

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
