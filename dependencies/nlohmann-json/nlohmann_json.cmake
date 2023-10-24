set(LIBJSON_PREFIX      json3112)
set(LIBJSON_GIT_REPO    "https://github.com/nlohmann/json.git")
set(LIBJSON_GIT_TAG     "v3.11.2")
set(LIBJSON_GIT_COMMIT  "bc889afb4c5bf1c0d8ee29ef35eaaf4c8bef8a5d")

set(LIBJSON_TOP_DIR ${PROJECT_BINARY_DIR}/${LIBJSON_PREFIX})
set(LIBJSON_DOWNLOAD_DIR ${LIBJSON_TOP_DIR}/src)
set(LIBJSON_SRC_DIR ${LIBJSON_DOWNLOAD_DIR}/${LIBJSON_PREFIX})
set(LIBJSON_INCLUDE_DIR ${LIBJSON_SRC_DIR}/include)
set(LIBJSON_BIN_DIR ${LIBJSON_SRC_DIR}/build)
set(LIBJSON_DEBUG_BUILD_DIR   ${LIBJSON_BIN_DIR}/debug)
set(LIBJSON_RELEASE_BUILD_DIR ${LIBJSON_BIN_DIR}/release)

ExternalProject_Add(${LIBJSON_PREFIX}
  PREFIX ${LIBJSON_PREFIX}
  GIT_REPOSITORY ${LIBJSON_GIT_REPO}
  GIT_TAG ${LIBJSON_GIT_TAG}
  DOWNLOAD_DIR  ${LIBJSON_DOWNLOAD_DIR}
  SOURCE_DIR    ${LIBJSON_SRC_DIR}
  LOG_DOWNLOAD 1
  CONFIGURE_COMMAND ""
  BUILD_IN_SOURCE 1
  LOG_BUILD 0
  BUILD_COMMAND ""
  INSTALL_COMMAND ""
  STEP_TARGETS configure build
  )

ExternalProject_Get_Property(${LIBJSON_PREFIX} DOWNLOAD_DIR)
ExternalProject_Get_Property(${LIBJSON_PREFIX} SOURCE_DIR)
ExternalProject_Get_Property(${LIBJSON_PREFIX} BINARY_DIR)
ExternalProject_Get_Property(${LIBJSON_PREFIX} INSTALL_DIR)
ExternalProject_Get_Property(${LIBJSON_PREFIX} TMP_DIR)
ExternalProject_Get_Property(${LIBJSON_PREFIX} STAMP_DIR)
ExternalProject_Get_Property(${LIBJSON_PREFIX} LOG_DIR)

# set the include directory variable and include it
include_directories(${LIBJSON_INCLUDE_DIR})

message(STATUS "[${LIBJSON_PREFIX}] TOP directory      : ${LIBJSON_TOP_DIR}")
message(STATUS "[${LIBJSON_PREFIX}] Download directory : ${DOWNLOAD_DIR}")
message(STATUS "[${LIBJSON_PREFIX}] Source directory   : ${SOURCE_DIR}")
message(STATUS "[${LIBJSON_PREFIX}] Binary directory   : ${BINARY_DIR}")
message(STATUS "[${LIBJSON_PREFIX}] Install directory  : ${INSTALL_DIR}")
message(STATUS "[${LIBJSON_PREFIX}] Temp directory     : ${TMP_DIR}")
message(STATUS "[${LIBJSON_PREFIX}] Stamp directory    : ${STAMP_DIR}")
message(STATUS "[${LIBJSON_PREFIX}] Log directory      : ${LOG_DIR}")
message(STATUS "[${LIBJSON_PREFIX}] Include directory  : ${LIBJSON_INCLUDE_DIR}")
message(STATUS "[${LIBJSON_PREFIX}] Debug build dir    : ${LIBJSON_DEBUG_BUILD_DIR}")
message(STATUS "[${LIBJSON_PREFIX}] Release build dir  : ${LIBJSON_RELEASE_BUILD_DIR}")

set(LIBJSON_LIBRARY_DIR ${LIBJSON_SRC_DIR})

set(CMAKE_REQUIRED_INCLUDES_SAVE ${CMAKE_REQUIRED_INCLUDES})
set(CMAKE_REQUIRED_INCLUDES ${CMAKE_REQUIRED_INCLUDES} ${LIBJSON_INCLUDE_DIR})
check_include_file_cxx("include/nlohmann/json.hpp" HAVE_JSON)
set(CMAKE_REQUIRED_INCLUDES ${CMAKE_REQUIRED_INCLUDES_SAVE})

if(NOT HAVE_JSON)
  message(STATUS "[${LIBJSON_PREFIX}] Missing nlohmann Json")
  set(HAVE_JSON 1)
else()
  message(STATUS "[${LIBJSON_PREFIX}] found include/nlohmann/json.hpp")
endif()
