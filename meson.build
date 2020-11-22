project('bettercmath', 'd')

sources = files(
  'source/bettercmath/package.d',
  'source/bettercmath/matrix.d',
  'source/bettercmath/vector.d',
)
incdir = include_directories('source')

bettercmath = library('bettercmath',
  sources,
  include_directories: incdir,
)

bettercmath_dep = declare_dependency(include_directories: incdir, link_with: bettercmath)
