# Install script for directory: /Users/rtorr/personal/sea-packages/packages/double-conversion/1.1.6/_src/src/src

# Set the install prefix
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "/usr/local")
endif()
string(REGEX REPLACE "/$" "" CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

# Set the install configuration name.
if(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)
  if(BUILD_TYPE)
    string(REGEX REPLACE "^[^A-Za-z0-9_]+" ""
           CMAKE_INSTALL_CONFIG_NAME "${BUILD_TYPE}")
  else()
    set(CMAKE_INSTALL_CONFIG_NAME "Release")
  endif()
  message(STATUS "Install configuration: \"${CMAKE_INSTALL_CONFIG_NAME}\"")
endif()

# Set the component getting installed.
if(NOT CMAKE_INSTALL_COMPONENT)
  if(COMPONENT)
    message(STATUS "Install component: \"${COMPONENT}\"")
    set(CMAKE_INSTALL_COMPONENT "${COMPONENT}")
  else()
    set(CMAKE_INSTALL_COMPONENT)
  endif()
endif()

# Is this installation the result of a crosscompile?
if(NOT DEFINED CMAKE_CROSSCOMPILING)
  set(CMAKE_CROSSCOMPILING "FALSE")
endif()

# Set path to fallback-tool for dependency-resolution.
if(NOT DEFINED CMAKE_OBJDUMP)
  set(CMAKE_OBJDUMP "/usr/bin/objdump")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "lib" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/usr/local/lib/libdouble-conversion.a")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "/usr/local/lib" TYPE STATIC_LIBRARY FILES "/Users/rtorr/personal/sea-packages/packages/double-conversion/1.1.6/_build/src/libdouble-conversion.a")
  if(EXISTS "$ENV{DESTDIR}/usr/local/lib/libdouble-conversion.a" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}/usr/local/lib/libdouble-conversion.a")
    execute_process(COMMAND "/usr/bin/ranlib" "$ENV{DESTDIR}/usr/local/lib/libdouble-conversion.a")
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "dev" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/usr/local/include/double-conversion/bignum.h;/usr/local/include/double-conversion/cached-powers.h;/usr/local/include/double-conversion/diy-fp.h;/usr/local/include/double-conversion/double-conversion.h;/usr/local/include/double-conversion/fast-dtoa.h;/usr/local/include/double-conversion/fixed-dtoa.h;/usr/local/include/double-conversion/ieee.h;/usr/local/include/double-conversion/strtod.h;/usr/local/include/double-conversion/utils.h")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "/usr/local/include/double-conversion" TYPE FILE FILES
    "/Users/rtorr/personal/sea-packages/packages/double-conversion/1.1.6/_src/src/src/bignum.h"
    "/Users/rtorr/personal/sea-packages/packages/double-conversion/1.1.6/_src/src/src/cached-powers.h"
    "/Users/rtorr/personal/sea-packages/packages/double-conversion/1.1.6/_src/src/src/diy-fp.h"
    "/Users/rtorr/personal/sea-packages/packages/double-conversion/1.1.6/_src/src/src/double-conversion.h"
    "/Users/rtorr/personal/sea-packages/packages/double-conversion/1.1.6/_src/src/src/fast-dtoa.h"
    "/Users/rtorr/personal/sea-packages/packages/double-conversion/1.1.6/_src/src/src/fixed-dtoa.h"
    "/Users/rtorr/personal/sea-packages/packages/double-conversion/1.1.6/_src/src/src/ieee.h"
    "/Users/rtorr/personal/sea-packages/packages/double-conversion/1.1.6/_src/src/src/strtod.h"
    "/Users/rtorr/personal/sea-packages/packages/double-conversion/1.1.6/_src/src/src/utils.h"
    )
endif()

string(REPLACE ";" "\n" CMAKE_INSTALL_MANIFEST_CONTENT
       "${CMAKE_INSTALL_MANIFEST_FILES}")
if(CMAKE_INSTALL_LOCAL_ONLY)
  file(WRITE "/Users/rtorr/personal/sea-packages/packages/double-conversion/1.1.6/_build/src/install_local_manifest.txt"
     "${CMAKE_INSTALL_MANIFEST_CONTENT}")
endif()
