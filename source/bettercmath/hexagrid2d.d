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
    private alias FT = FloatType!T;
    private alias Mat2 = Matrix!(FT, 2);
    private alias Vec2 = Vector!(FT, 2);

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
            East = Hex(1, 0),
            E = East,
            NorthEast = Hex(1, -1),
            NE = NorthEast,
            NorthWest = Hex(0, -1),
            NW = NorthWest,
            West = Hex(-1, 0),
            W = West,
            SouthWest = Hex(-1, 1),
            SW = SouthWest,
            SouthEast = Hex(0, 1),
            SE = SouthEast,
        }
        private enum toPixelMatrix = Mat2.fromRows(
            sqrt3, sqrt3 / 2.0,
            0,     3.0 / 2.0
        );
        private enum fromPixelMatrix = Mat2.fromRows(
            sqrt3 / 3.0, -1.0 / 3.0,
            0,            2.0 / 3.0
        );
        private enum FT[6] angles = [30, 90, 150, 210, 270, 330];
    }
    else
    {
        enum Directions
        {
            SouthEast = Hex(1, 0),
            SE = SouthEast,
            NorthEast = Hex(1, -1),
            NE = NorthEast,
            North = Hex(0, -1),
            N = North,
            NorthWest = Hex(-1, 0),
            NW = NorthWest,
            SouthWest = Hex(-1, 1),
            SW = SouthWest,
            South = Hex(0, 1),
            S = South,
        }
        private enum toPixelMatrix = Mat2.fromRows(
            3.0 / 2.0,   0,
            sqrt3 / 2.0, sqrt3
        );
        private enum fromPixelMatrix = Mat2.fromRows(
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
    Hex opBinary(string op)(const Hex other) const
    if (op.among("+", "-"))
    {
        return Hex(this.coordinates.opBinary!op(other.coordinates));
    }

    Hex opBinary(string op : "*")(const int scale) const
    {
        Hex result;
        result.coordinates = coordinates * scale;
        return result;
    }

    T magnitude() const
    {
        import std.algorithm : sum;
        return cast(T)((fabs(q) + fabs(r) + fabs(s)) / 2);
    }

    T distanceTo(const Hex other) const
    {
        Hex vector = this - other;
        return vector.magnitude();
    }

    Vec2 centerPixel(const Vec2 origin, const Vec2 size) const
    {
        typeof(return) result = toPixelMatrix * cast(Vec2) coordinates;
        return result * size + origin;
    }

    static Vec2[6] corners(const FT sizeX, const FT sizeY)
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
