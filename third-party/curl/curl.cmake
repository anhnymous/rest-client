set(LIBCURL_PREFIX      curl800)
set(LIBCURL_GIT_REPO    "https://github.com/curl/curl")
set(LIBCURL_GIT_TAG     "curl-8_0_0")
set(LIBCURL_GIT_COMMIT  "47ccaa4218c408e70671a2fa9caaa3caf8c1a877")

if(WIN32)
  set(MAKE_CMD gmake)
elseif(UNIX)
  set(MAKE_CMD make)
else()
  set(MAKE_CMD make)
endif()

set(LIBCURL_TOP_DIR ${PROJECT_BINARY_DIR}/${LIBCURL_PREFIX})
set(LIBCURL_DOWNLOAD_DIR ${LIBCURL_TOP_DIR}/src)
set(LIBCURL_SRC_DIR ${LIBCURL_DOWNLOAD_DIR}/${LIBCURL_PREFIX})
set(LIBCURL_INCLUDE_DIR ${LIBCURL_SRC_DIR}/include)
set(LIBCURL_BIN_DIR ${LIBCURL_SRC_DIR}/build)
set(LIBCURL_DEBUG_BUILD_DIR   ${LIBCURL_BIN_DIR}/debug)
set(LIBCURL_RELEASE_BUILD_DIR ${LIBCURL_BIN_DIR}/release)

ExternalProject_Add(${LIBCURL_PREFIX}
  PREFIX ${LIBCURL_PREFIX}
  GIT_REPOSITORY ${LIBCURL_GIT_REPO}
  GIT_TAG ${LIBCURL_GIT_TAG}
  DOWNLOAD_DIR  ${LIBCURL_DOWNLOAD_DIR}
  SOURCE_DIR    ${LIBCURL_SRC_DIR}
  LOG_DOWNLOAD YES
  LOG_CONFIGURE YES
  CONFIGURE_COMMAND \;
  ${CMAKE_COMMAND} -E echo "== Info: Starting custom configure libcurl"
  COMMAND autoreconf -i ${BINARY_DIR}
  COMMAND ./configure --with-openssl --enable-versioned-symbols ${BINARY_DIR}
  COMMAND ${CMAKE_COMMAND} -E echo "== Info: Custom configure libcurl completed"
  LOG_BUILD YES
  BUILD_IN_SOURCE 1
  CMAKE_CACHE_ARGS \;
    -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=TRUE \;
    -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}/${LIBCURL_PREFIX}
  BUILD_COMMAND ${MAKE_CMD} -j8 ${SOURCE_DIR}
  INSTALL_DIR "${CMAKE_CURRENT_BINARY_DIR}"
  INSTALL_COMMAND ""
  STEP_TARGETS configure build
)

ExternalProject_Get_Property(${LIBCURL_PREFIX} DOWNLOAD_DIR)
ExternalProject_Get_Property(${LIBCURL_PREFIX} SOURCE_DIR)
ExternalProject_Get_Property(${LIBCURL_PREFIX} BINARY_DIR)
ExternalProject_Get_Property(${LIBCURL_PREFIX} INSTALL_DIR)
ExternalProject_Get_Property(${LIBCURL_PREFIX} TMP_DIR)
ExternalProject_Get_Property(${LIBCURL_PREFIX} STAMP_DIR)
ExternalProject_Get_Property(${LIBCURL_PREFIX} LOG_DIR)

include_directories(${LIBCURL_INCLUDE_DIR})

message(STATUS "[${LIBCURL_PREFIX}] TOP directory      : ${LIBCURL_TOP_DIR}")
message(STATUS "[${LIBCURL_PREFIX}] Download directory : ${DOWNLOAD_DIR}")
message(STATUS "[${LIBCURL_PREFIX}] Source directory   : ${SOURCE_DIR}")
message(STATUS "[${LIBCURL_PREFIX}] Binary directory   : ${BINARY_DIR}")
message(STATUS "[${LIBCURL_PREFIX}] Install directory  : ${INSTALL_DIR}")
message(STATUS "[${LIBCURL_PREFIX}] Temp directory     : ${TMP_DIR}")
message(STATUS "[${LIBCURL_PREFIX}] Stamp directory    : ${STAMP_DIR}")
message(STATUS "[${LIBCURL_PREFIX}] Log directory      : ${LOG_DIR}")
message(STATUS "[${LIBCURL_PREFIX}] Include directory  : ${LIBCURL_INCLUDE_DIR}")
message(STATUS "[${LIBCURL_PREFIX}] Debug build dir    : ${LIBCURL_DEBUG_BUILD_DIR}")
message(STATUS "[${LIBCURL_PREFIX}] Release build dir  : ${LIBCURL_RELEASE_BUILD_DIR}")

if(CMAKE_BUILD_TYPE STREQUAL "Debug")
  set(LIBCURL_LIBRARY_DIR ${BINARY_DIR}/lib/.libs/)
  message(STATUS "[${LIBCURL_PREFIX}] LIBCURL_LIBRARY_DIR: ${LIBCURL_LIBRARY_DIR}")
  message(STATUS "[${LIBCURL_PREFIX}] ${LIBCURL_PREFIX} Debug build type")
else()
  set(LIBCURL_LIBRARY_DIR ${BINARY_DIR}/lib/.libs/)
  message(STATUS "[${LIBCURL_PREFIX}] LIBCURL_LIBRARY_DIR: ${LIBCURL_LIBRARY_DIR}")
  message(STATUS "[${LIBCURL_PREFIX}] ${LIBCURL_PREFIX} Release build type")
endif()

set(CMAKE_REQUIRED_INCLUDES_SAVE ${CMAKE_REQUIRED_INCLUDES})
set(CMAKE_REQUIRED_INCLUDES ${CMAKE_REQUIRED_INCLUDES} ${LIBCURL_INCLUDE_DIR})
check_include_file_cxx("curl/curl.h" HAVE_CURL)
set(CMAKE_REQUIRED_INCLUDES ${CMAKE_REQUIRED_INCLUDES_SAVE})
if(NOT HAVE_CURL)
  message(STATUS "Did not build libcurl correctly as cannot find curl.h")
  set(HAVE_CURL 1)
else()
  message(STATUS "[${LIBCURL_PREFIX}] found curl/curl.h")
endif()

if(UNIX)
  install(DIRECTORY ${LIBCURL_LIBRARY_DIR}/ DESTINATION lib
          USE_SOURCE_PERMISSIONS FILES_MATCHING PATTERN "*.so*")
endif()
