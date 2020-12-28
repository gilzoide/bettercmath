## [Unreleased]
### Added
- `Matrix.copyInto` function that copies values between matrices of any dimensions
- `Matrix.opCast` function to cast between matrices of different dimensions
- `TransformOptions` enum for specifying template options, for now if Transform
  should use a compact matrix type
- `Transform.copyInto` function that copies a Transform into another
- `Transform.copyInto` function that copies a Transform into a Transform-like
  Matrix type (NxN or NxN-1)
- `Transform.opCast` function to cast between Transform types

### Changed
- Added `auto ref` to several Matrix and some Vector functions' arguments

### Removed
- Transform template compact parameter, in favor of `TransformOptions`
- Transfrom's `full`, `compact`, `fullInto` and `compactInto` functions,
  in favor of `copyInto` and `opCast`


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

[Unreleased]: https://github.com/gilzoide/bettercmath/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/gilzoide/bettercmath/releases/tag/v0.1.0