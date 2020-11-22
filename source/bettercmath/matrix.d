module bettercmath.matrix;

import bettercmath.vector;
import core.stdc.math;
import std.math : PI;
import std.traits;

struct Matrix(T, uint _numColumns, uint _numRows = _numColumns)
if (isFloatingPoint!T && _numColumns > 0 && _numRows > 0)
{
    private alias Self = typeof(this);

    enum numColumns = _numColumns;
    enum numRows = _numRows;

    Vector!(T, numColumns)[numRows] columns;
    alias columns this;

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

            float cotangent = 1.0 / tanf(fov * (PI / 360.0));

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
    alias Mat4 = Matrix!(float, 4);
}
