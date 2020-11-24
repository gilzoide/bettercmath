module bettercmath.hexagrid2d;

import bettercmath.angles;
import bettercmath.cmath;
import bettercmath.vector;
import bettercmath.matrix;
import std.algorithm : among;
import std.traits : isFloatingPoint;

private enum sqrt3 = sqrt(3);

version (unittest)
{
    private alias Hexi = Hex!(Orientation.pointy, int);
    private alias Hexif = Hex!(Orientation.flat, int);
}

enum Orientation
{
    pointy,
    flat,
}

struct Hex(Orientation orientation, T = int)
{
    private alias Self = typeof(this);
    private alias FT = FloatType!T;
    private alias Mat2 = Matrix!(float, 2);

    /// Axial coordinates, see https://www.redblobgames.com/grids/hexagons/implementation.html
    private const Vector!(T, 2) coordinates;
    
    @property T q() const
    {
        return coordinates[0];
    }
    @property T r() const
    {
        return coordinates[1];
    }
    @property T s() const
    {
        return -q -r;
    }

    static if (orientation == Orientation.pointy)
    {
        enum Directions
        {
            East = Self(1, 0),
            E = East,
            NorthEast = Self(1, -1),
            NE = NorthEast,
            NorthWest = Self(0, -1),
            NW = NorthWest,
            West = Self(-1, 0),
            W = West,
            SouthWest = Self(-1, 1),
            SW = SouthWest,
            SouthEast = Self(0, 1),
            SE = SouthEast,
        }
        private enum toPixelMatrix = Mat2(
            sqrt3, sqrt3 / 2.0,
            0,     3.0 / 2.0
        );
        private enum fromPixelMatrix = Mat2(
            sqrt3 / 3.0, -1.0 / 3.0,
            0,            2.0 / 3.0
        );
        private enum FT[6] angles = [30, 90, 150, 210, 270, 330];
    }
    else
    {
        enum Directions
        {
            SouthEast = Self(1, 0),
            SE = SouthEast,
            NorthEast = Self(1, -1),
            NE = NorthEast,
            North = Self(0, -1),
            N = North,
            NorthWest = Self(-1, 0),
            NW = NorthWest,
            SouthWest = Self(-1, 1),
            SW = SouthWest,
            South = Self(0, 1),
            S = South,
        }
        private enum toPixelMatrix = Mat2(
            3.0 / 2.0,   0,
            sqrt3 / 2.0, sqrt3
        );
        private enum fromPixelMatrix = Mat2(
            2.0 / 3.0,  0,
            -1.0 / 3.0, sqrt3 / 3.0
        );
        private enum FT[6] angles = [0, 60, 120, 180, 240, 300];
    }
    
    this(T q, T r)
    {
        coordinates = [q, r];
    }
    this(T[2] coordinates)
    {
        this.coordinates = coordinates;
    }

    // Operations
    Self opBinary(string op)(Self other) const
    if (op.among("+", "-"))
    {
        return Self(this.coordinates.opBinary!op(other.coordinates));
    }

    Self opBinary(string op : "*")(int scale) const
    {
        Self result;
        result.coordinates = coordinates * scale;
        return result;
    }

    T magnitude() const
    {
        import std.algorithm : sum;
        return cast(T)((fabs(q) + fabs(r) + fabs(s)) / 2);
    }

    T distanceTo(Self other) const
    {
        Self vector = this - other;
        return vector.magnitude();
    }

    static Vector!(FT, 2)[6] corners(FT sizeX, FT sizeY)
    {
        typeof(return) result = void;
        foreach (i; 0 .. 6)
        {
            FT angle = deg2rad(angles[i]);
            result[i] = [sizeX * cos(angle), sizeY * sin(angle)];
        }
        return result;
    }
}

unittest
{
    alias Hexi = Hex!(Orientation.pointy, int);
}
