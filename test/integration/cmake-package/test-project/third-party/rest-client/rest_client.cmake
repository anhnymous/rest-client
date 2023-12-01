set(LIBRC_PREFIX      restclient010)
set(LIBRC_GIT_REPO    "git@github-anhnymous:anhnymous/rest-client.git")
set(LIBRC_GIT_TAG     "")
set(LIBRC_GIT_COMMIT  "b6f54fcb082d4ee3008c65ebdd51a3181585ac23")

set(LIBRC_TOP_DIR ${PROJECT_BINARY_DIR}/${LIBRC_PREFIX})
set(LIBRC_DOWNLOAD_DIR ${LIBRC_TOP_DIR}/src)
set(LIBRC_SRC_DIR ${LIBRC_DOWNLOAD_DIR}/${LIBRC_PREFIX})
set(LIBRC_INCLUDE_DIR ${LIBRC_SRC_DIR}/src/rest-client)
set(LIBRC_BIN_DIR ${LIBRC_SRC_DIR}/build)
set(LIBRC_DEBUG_BUILD_DIR   ${LIBRC_BIN_DIR}/debug)
set(LIBRC_RELEASE_BUILD_DIR ${LIBRC_BIN_DIR}/release)

include_directories(${LIBRC_INCLUDE_DIR})

if(WIN32)
  set(MAKE_COMMAND gmake)
elseif(UNIX)
  set(MAKE_COMMAND make)
else()
  set(MAKE_COMMAND make)
endif()
message(STATUS "[${LIBRC_PREFIX}] CMAKE_COMMAND: ${CMAKE_COMMAND}")
message(STATUS "[${LIBRC_PREFIX}] MAKE_COMMAND: ${MAKE_COMMAND}")

ExternalProject_Add(${LIBRC_PREFIX}
  PREFIX ${LIBRC_PREFIX}
  GIT_REPOSITORY ${LIBRC_GIT_REPO}
  GIT_TAG ${LIBRC_GIT_COMMIT}
  DOWNLOAD_DIR  ${LIBRC_DOWNLOAD_DIR}
  SOURCE_DIR    ${LIBRC_SRC_DIR}
  LOG_DOWNLOAD 1
  LOG_CONFIGURE 1
  CONFIGURE_COMMAND \;
  ${CMAKE_COMMAND} -E echo "== Info: Starting custom configure lib rest-client"
  COMMAND ${CMAKE_COMMAND} -DSHARED_LIB=ON .
  COMMAND ${CMAKE_COMMAND} -E echo "== Info: Custom configure lib rest-client completed"
  LOG_BUILD 1
  BUILD_IN_SOURCE 1
  BUILD_COMMAND ${MAKE_COMMAND} -j8 ${BINARY_DIR}
  INSTALL_DIR "${CMAKE_CURRENT_BINARY_DIR}"
  INSTALL_COMMAND ""
  STEP_TARGETS configure build)

ExternalProject_Get_Property(${LIBRC_PREFIX} DOWNLOAD_DIR)
ExternalProject_Get_Property(${LIBRC_PREFIX} SOURCE_DIR)
ExternalProject_Get_Property(${LIBRC_PREFIX} BINARY_DIR)
ExternalProject_Get_Property(${LIBRC_PREFIX} INSTALL_DIR)
ExternalProject_Get_Property(${LIBRC_PREFIX} TMP_DIR)
ExternalProject_Get_Property(${LIBRC_PREFIX} STAMP_DIR)
ExternalProject_Get_Property(${LIBRC_PREFIX} LOG_DIR)
message(STATUS "[${LIBRC_PREFIX}] TOP directory      : ${LIBRC_TOP_DIR}")
message(STATUS "[${LIBRC_PREFIX}] Download directory : ${DOWNLOAD_DIR}")
message(STATUS "[${LIBRC_PREFIX}] Source directory   : ${SOURCE_DIR}")
message(STATUS "[${LIBRC_PREFIX}] Binary directory   : ${BINARY_DIR}")
message(STATUS "[${LIBRC_PREFIX}] Install directory  : ${INSTALL_DIR}")
message(STATUS "[${LIBRC_PREFIX}] Temp directory     : ${TMP_DIR}")
message(STATUS "[${LIBRC_PREFIX}] Stamp directory    : ${STAMP_DIR}")
message(STATUS "[${LIBRC_PREFIX}] Log directory      : ${LOG_DIR}")
message(STATUS "[${LIBRC_PREFIX}] Include directory  : ${LIBRC_INCLUDE_DIR}")
message(STATUS "[${LIBRC_PREFIX}] Debug build dir    : ${LIBRC_DEBUG_BUILD_DIR}")
message(STATUS "[${LIBRC_PREFIX}] Release build dir  : ${LIBRC_RELEASE_BUILD_DIR}")

if(CMAKE_BUILD_TYPE STREQUAL "Debug")
  set(LIBRC_LIBRARY_DIR ${BINARY_DIR}/lib)
  message(STATUS "[${LIBRC_PREFIX}] LIBRC_LIBRARY_DIR: ${LIBRC_LIBRARY_DIR}")
  message(STATUS "[${LIBRC_PREFIX}] ${LIBRC_PREFIX} Debug build type")
else()
  set(LIBRC_LIBRARY_DIR ${BINARY_DIR}/lib)
  message(STATUS "[${LIBRC_PREFIX}] LIBRC_LIBRARY_DIR: ${LIBRC_LIBRARY_DIR}")
  message(STATUS "[${LIBRC_PREFIX}] ${LIBRC_PREFIX} Release build type")
endif()
