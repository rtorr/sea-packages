#----------------------------------------------------------------
# Generated CMake target import file for configuration "Release".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "double-conversion" for configuration "Release"
set_property(TARGET double-conversion APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(double-conversion PROPERTIES
  IMPORTED_LINK_INTERFACE_LANGUAGES_RELEASE "CXX"
  IMPORTED_LOCATION_RELEASE "/usr/local/lib/libdouble-conversion.a"
  )

list(APPEND _cmake_import_check_targets double-conversion )
list(APPEND _cmake_import_check_files_for_double-conversion "/usr/local/lib/libdouble-conversion.a" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
