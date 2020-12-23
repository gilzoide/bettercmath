# bettercmath
A `-betterC` compatible 3D math library for [D](https://dlang.org/).

It is available as a [DUB package](https://code.dlang.org/packages/bettercmath)
and may be used directly as a [Meson subproject](https://mesonbuild.com/Subprojects.html)
or [wrap](https://mesonbuild.com/Wrap-dependency-system-manual.html).

## Submodules

- **cmath**: Standard math type generic functions and constants, using D runtime ([std.math](https://dlang.org/phobos/std_math.html)) on CTFE and C runtime ([core.stdc.math](https://dlang.org/phobos/core_stdc_math.html)) otherwise
- **easings**: Type generic easing functions based on https://easings.net
- **hexagrid2d**: 2D Hexagon grid math based on https://www.redblobgames.com/grids/hexagons
- **matrix**: Type generic Matrices for use in linear algebra
- **misc**: Miscelaneous math functions (angle measure transformation, type generic linear interpolation)
- **transform**: Type and dimension generic Affine transformations backed by possibly compacted Matrices
- **valuerange**: Inclusive scalar value ranges for interpolating and remapping between ranges
- **vector**: Fixed dimension vectors/points;
