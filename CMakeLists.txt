########################################################################################
# rest-client: Simple REST client implemented in C/C++ and using libcurl.
# COPYRIGHT: (c) 2022 Anh Tran
# Author: Anh Tran
# File: CMakeLists.txt
# License: GPLv3
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.
########################################################################################
cmake_minimum_required(VERSION 3.21)
project(rest_client VERSION 0.1.0 LANGUAGES C CXX DESCRIPTION "C++ REST client")
message(STATUS "PROJECT_NAME: ${PROJECT_NAME}")
message(STATUS "PROJECT_VERSION: ${PROJECT_VERSION}")

include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

set(CMAKE_C_STANDARD 17)
set(CMAKE_CXX_STANDARD 17)
if(CMAKE_CROSSCOMPILING)
  set(not_crosscompiling OFF)
else()
  set(not_crosscompiling ON)
endif()

set(POSITION_INDEPENDENT_CODE ON)
option(DEBUG "Build `rest-client` optimized for GDB debugging" OFF)
if(DEBUG)
  message(STATUS "[${PROJECT_NAME}] DEBUG build enabled")
  set(CMAKE_BUILD_TYPE "Debug")
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -O0 -ggdb3")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O0 -ggdb3")
else()
  message(STATUS "[${PROJECT_NAME}] RELEASE build enabled")
  set(CMAKE_BUILD_TYPE "Release")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -ftree-vectorize")
endif()

if(CMAKE_BUILD_TYPE STREQUAL "Debug")
  message(STATUS "[${PROJECT_NAME}] CMAKE_BUILD_TYPE is Debug")
else()
  message(STATUS "[${PROJECT_NAME}] CMAKE_BUILD_TYPE is Release")
endif()

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=gnu++17")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wfloat-equal")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wduplicated-cond")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wformat-security")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wdouble-promotion")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -D_FORTIFY_SOURCE=2")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wlogical-not-parentheses")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIE -Wextra -Wall -Werror")

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib")
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib")
set(CMAKE_INCLUDE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/include")
set(CMAKE_INSTALL_CMAKEDIR "${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}")

configure_package_config_file(
  "PackageConfig.cmake.in" "${PROJECT_NAME}Config.cmake"
  INSTALL_DESTINATION "${CMAKE_INSTALL_CMAKEDIR}")
write_basic_package_version_file(
  "${PROJECT_NAME}ConfigVersion.cmake"
  VERSION ${PROJECT_VERSION}
  COMPATIBILITY SameMajorVersion)
install(
  FILES "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}Config.cmake"
        "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake"
  DESTINATION "${CMAKE_INSTALL_CMAKEDIR}"
  COMPONENT dev)

configure_file(
  "PkgConfig.pc.in"
  "${PROJECT_NAME}.pc"
  @ONLY
)
install(
  FILES "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.pc"
  DESTINATION "${CMAKE_INSTALL_LIBDIR}/pkgconfig"
  COMPONENT dev
)

include(ExternalProject)
include(CheckIncludeFile)
include(CheckIncludeFiles)
include(CheckIncludeFileCXX)
include(third-party/curl/curl.cmake)
include(third-party/nlohmann-json/nlohmann_json.cmake)

add_subdirectory(third-party)

find_library(CURL_LIBS
  NAMES curl libcurl
  HINTS ${LIBCURL_LIBRARY_DIR}
  NO_CACHE
  NO_DEFAULT_PATH
  NO_CMAKE_SYSTEM_PATH
)
if(CURL_LIBS_FOUND)
  message(STATUS "[${PROJECT_NAME}] Found libcurl at: ${CURL_LIBS}")
else()
  set(CURL_LIBS "curl")
endif()

if(HAVE_CURL)
  message(STATUS "[${PROJECT_NAME}] CURL_LIBS          : ${CURL_LIBS}")
  message(STATUS "[${PROJECT_NAME}] LIBCURL_LIBRARY_DIR: ${LIBCURL_LIBRARY_DIR}")
  message(STATUS "[${PROJECT_NAME}] LIBCURL_INCLUDE_DIR: ${LIBCURL_INCLUDE_DIR}")
endif()

if(HAVE_JSON)
  message(STATUS "[${PROJECT_NAME}] LIBJSON_LIBRARY_DIR: ${LIBJSON_LIBRARY_DIR}")
  message(STATUS "[${PROJECT_NAME}] LIBJSON_INCLUDE_DIR: ${LIBJSON_INCLUDE_DIR}")
endif()

set(SRC_FILES
  ${PROJECT_SOURCE_DIR}/src/rest-client/rest_client.cc)
set(PUBLIC_HEADERS
  ${PROJECT_SOURCE_DIR}/src/rest-client/rest_client.hh)

option(SHARED_LIB "Build shared library." OFF)
if(SHARED_LIB)
  message(STATUS "[${PROJECT_NAME}] build `rest-client` as shared library")
  set(CMAKE_SHARED_LINKER_FLAGS "-Wl,--export-dynamic")
  add_library(${PROJECT_NAME} SHARED ${SRC_FILES})
  target_link_libraries(${PROJECT_NAME} PRIVATE ${CURL_LIBS})
  target_include_directories(${PROJECT_NAME} PRIVATE ${LIBCURL_INCLUDE_DIR})
  target_include_directories(${PROJECT_NAME} PRIVATE ${LIBJSON_INCLUDE_DIR})
else()
  message(STATUS "[${PROJECT_NAME}] build `rest-client` as static library")
  add_library(${PROJECT_NAME} STATIC ${SRC_FILES})
  target_link_libraries(${PROJECT_NAME} PRIVATE ${CURL_LIBS})
  target_include_directories(${PROJECT_NAME} PRIVATE ${LIBCURL_INCLUDE_DIR})
  target_include_directories(${PROJECT_NAME} PRIVATE ${LIBJSON_INCLUDE_DIR})
endif()
set_target_properties(${PROJECT_NAME} PROPERTIES VERSION ${PROJECT_VERSION})
file(COPY ${PUBLIC_HEADERS} DESTINATION ${CMAKE_INCLUDE_OUTPUT_DIRECTORY})

add_dependencies(${PROJECT_NAMAE} ${LIBCURL_PREFIX} ${LIBJSON_PREFIX})
install(TARGETS ${PROJECT_NAME}
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  COMPONENT dev)
set_target_properties(${PROJECT_NAME}
  PROPERTIES
  PUBLIC_HEADER "${PUBLIC_HEADERS}")
install(TARGETS ${PROJECT_NAME}
  PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
  COMPONENT dev)

option(TESTING "Build tests." OFF)
if(TESTING)
  include(CTest)
  enable_testing()
  add_subdirectory(test/basic)
endif()

add_custom_target("uninstall" COMMENT "Uninstall installed files")
add_custom_command(
  TARGET "uninstall"
  POST_BUILD
  COMMENT "Uninstall files with install_manifest.txt"
  COMMAND xargs rm -vf < install_manifest.txt || echo Nothing in
          install_manifest.txt to be uninstalled!)
