## [Unreleased]
### Added
- Setter functions for `BoundingBox.center` property
- `Vector.opBinaryRight` with static arrays
- `Vector` constructor from a Vector-like struct, that is, one
  with all fields of same type
- `Vector.opCast` for a Vector-like struct type, that is, one
  with all fields of same type

### Changed
- Renamed `BoundingBox.start` to `BoundingBox.origin`
- Added support for static arrays as arguments in `BoundingBox`

### Fixed
- Variadic `Vector` constructor to be called only if more
  than one argument is passed


## [0.3.1] - 2021-01-25
### Added
- `Vector.opBinary` and `Vector.opBinaryRight` versions that accepts non-T arguments

### Fixed
- Import valuerange in package.d
- Avoid overflow/underflow in `lerp`
- Make `Vector._get` and `Vector._slice` public

## [0.3.0] - 2021-01-15
### Added
- **box** submodule, with type and dimension generic axis-aligned bounding box template
- `width`, `height` and `depth` aliases for `Vector` elements
- `vector` overload that receive elements and infers element type using `std.traits.CommonType`

### Changed
- Changed target type to source library in `dub.json` and `meson.build`,
  as all package functionality is within templates

### Fixed
- Purity of Vector constructor with Range argument

### Removed
- `vector.map` function, use `std.range.map` instead


## [0.2.0] - 2020-12-28
### Added
- `Matrix.copyInto` function that copies values between matrices of any dimensions
- `Matrix.opCast` function to cast between matrices of different dimensions
- `TransformOptions` enum for specifying template options, for now if Transform
  should use a compact matrix type
- `Transform.copyInto` function that copies a Transform into another
- `Transform.copyInto` function that copies a Transform into a Transform-like
  Matrix type (NxN or NxN-1)
- `Transform.opCast` function to cast between Transform types
- `EasingFunction` alias to easing functions' type
- This CHANGELOG file

### Changed
- Added `auto ref` to several Matrix and Vector functions' arguments
- Changed `Vector.opCast` to accept `T2[N]` instead of `Vector!(T2, N)`
- Forced easing functions return types to `T`

### Fixed
- Shearing transformations when passing a single value

### Removed
- Transform template compact parameter, in favor of `TransformOptions`
- Transfrom's `full`, `compact`, `fullInto` and `compactInto` functions,
  in favor of `copyInto` and `opCast`
- Shearing transformations for 1D Transforms


## [0.1.0] - 2020-12-23
### Added
- DUB package manifest
- Meson project file
- README file with an overview about the package and it's submodules
- **cmath** submodule, with type generic standard math function wrappers
- **easings** submodule, with type generic easing functions
- **hexagrid2d** submodule, with 2D hexagon grid math functionality
- **matrix** submodule, with type generic matrices
- **misc** submodule, with miscelaneous functions
- **transform** submodule, with type and dimension generic affine
  transformation matrices
- **valuerange** submodule, with type generic scalar value ranges for
  value interpolation and remapping
- **vector** submodule, with type and dimension generic vector math

[Unreleased]: https://github.com/gilzoide/bettercmath/compare/v0.3.1...HEAD
[0.3.1]: https://github.com/gilzoide/bettercmath/compare/v0.3.0...v0.3.1
[0.3.0]: https://github.com/gilzoide/bettercmath/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/gilzoide/bettercmath/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/gilzoide/bettercmath/releases/tag/v0.1.0
