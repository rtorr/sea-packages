file(REMOVE_RECURSE
  ".0.58.0-dev"
  "libfolly.0.58.0-dev.dylib"
  "libfolly.dylib"
  "libfolly.pdb"
)

# Per-language clean rules from dependency scanning.
foreach(lang CXX)
  include(CMakeFiles/folly.dir/cmake_clean_${lang}.cmake OPTIONAL)
endforeach()
