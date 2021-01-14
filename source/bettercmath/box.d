/**
 * Type and dimension generic Axis-Aligned Bounding Box (AABB).
 */
module bettercmath.box;

@safe @nogc nothrow:

/// Options for the BoundingBox template.
enum BoundingBoxOptions
{
    /// Default options: store `max` corner information and derive `size`.
    none = 0,
    /// Store `size` information and derive `max` corner.
    storeSize = 1,
}

/**
 * Generic Axis-Aligned Bounding Box.
 *
 * May be stored as the starting and ending corners,
 * or as starting point and size.
 *
 * Params:
 *   T = Element type
 *   N = Box dimension, must be positive
 *   options = Additional options, like storage meaning
 */
struct BoundingBox(T, uint Dim, BoundingBoxOptions options = BoundingBoxOptions.none)
if (Dim > 0)
{
    import bettercmath.vector : Vector;

    alias ElementType = T;
    /// Bounding Box dimension.
    enum dimension = Dim;
    /// Point type, a Vector with the same type and dimension.
    alias Point = Vector!(T, Dim);
    /// Size type, a Vector with the same type and dimension.
    alias Size = Vector!(T, Dim);

    /// Minimum Box corner.
    Point min = 0;

    static if (options & BoundingBoxOptions.storeSize)
    {
        /// Size of a Box, may be negative.
        Size size = 1;

        /// Get the `max` corner of a Box.
        @property Point max() const
        {
            return min + size;
        }
        /// Set the `max` corner of a Box.
        @property void max(const Point value)
        {
            size = value - min;
        }
    }
    else
    {
        /// Maximum Box corner.
        Point max = 1;

        /// Get the size of a Box, may be negative.
        @property Size size() const
        {
            return max - min;
        }
        /// Set the size of a Box, using `min` as the pivot.
        @property void size(const Size value)
        {
            max = min + value;
        }
    }

    /// Get the width of a Box, may be negative.
    @property T width() const
    {
        return size.width;
    }
    /// Set the width of a Box, using `min` as the pivot.
    @property void width(const T value)
    {
        auto s = size;
        s.width = value;
        size = s;
    }

    static if (Dim >= 2)
    {
        /// Get the height of a Box, may be negative.
        @property T height() const
        {
            return size.height;
        }
        /// Set the height of a Box, using `min` as the pivot.
        @property void height(const T value)
        {
            auto s = size;
            s.height = value;
            size = s;
        }
    }
    static if (Dim >= 3)
    {
        /// Get the depth of a Box, may be negative.
        @property T depth() const
        {
            return size.depth;
        }
        /// Set the depth of a Box, using `min` as the pivot.
        @property void depth(const T value)
        {
            auto s = size;
            s.depth = value;
            size = s;
        }
    }

    /// Get the central point of Box.
    @property Point center() const
    {
        return (min + max) / 2;
    }

    /// Get the volume of the Box.
    @property T volume() const
    {
        import std.algorithm : fold;
        return size.fold!"a * b";
    }

    static if (Dim == 2)
    {
        /// 2D area is the same as generic box volume.
        alias area = volume;
    }

    static if (Dim == 3)
    {
        /// Get the surface area of a 3D Box.
        @property T surfaceArea() const
        {
            auto s = size;
            return 2 * (s.x * s.y + s.y * s.z + s.x * s.z);
        }
    }
}

/// Common alias for Bounding Boxes.
alias AABB = BoundingBox;
