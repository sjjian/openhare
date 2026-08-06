# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.10)

project(go_impl_library VERSION 0.0.1 LANGUAGES C)

find_program(GO_EXECUTABLE go)
if(NOT GO_EXECUTABLE)
  message(FATAL_ERROR "go executable not found. Install Go to build go_impl.")
endif()

set(GO_IMPL_GO_DIR "${CMAKE_CURRENT_SOURCE_DIR}")
if(WIN32)
  set(GO_IMPL_SHARED_LIB "${CMAKE_CURRENT_BINARY_DIR}/go_impl.dll")
elseif(APPLE)
  set(GO_IMPL_SHARED_LIB "${CMAKE_CURRENT_BINARY_DIR}/libgo_impl.dylib")
else()
  set(GO_IMPL_SHARED_LIB "${CMAKE_CURRENT_BINARY_DIR}/libgo_impl.so")
endif()
set(GO_IMPL_SHARED_HEADER "${CMAKE_CURRENT_BINARY_DIR}/libgo_impl.h")

# Shared c-shared build for Linux / Windows / macOS (podspec invokes this via cmake).
# On Windows, duckdb-go only ships windows-amd64 MinGW static libs
# (#cgo LDFLAGS: -lstdc++ --static -lws2_32 …); Flutter's MSVC toolchain cannot
# link them, so force MinGW gcc/g++ and GOARCH=amd64. c-shared embeds those libs.
set(_go_impl_build_commands)

if(WIN32)
  string(TOLOWER "${CMAKE_SYSTEM_PROCESSOR}" _go_impl_proc)
  if(CMAKE_GENERATOR_PLATFORM)
    string(TOLOWER "${CMAKE_GENERATOR_PLATFORM}" _go_impl_plat)
  else()
    set(_go_impl_plat "")
  endif()
  if(_go_impl_plat MATCHES "arm64" OR _go_impl_proc MATCHES "arm64|aarch64")
    message(FATAL_ERROR
      "go_impl: duckdb-go has no windows-arm64 prebuilt libs; only windows-amd64 is supported.")
  endif()

  find_program(GO_IMPL_MINGW_CC NAMES gcc x86_64-w64-mingw32-gcc)
  find_program(GO_IMPL_MINGW_CXX NAMES g++ x86_64-w64-mingw32-g++)
  if(NOT GO_IMPL_MINGW_CC OR NOT GO_IMPL_MINGW_CXX)
    message(FATAL_ERROR
      "go_impl: MinGW gcc/g++ not found. duckdb-go requires MinGW-w64 on Windows "
      "(e.g. MSYS2: pacman -S mingw-w64-ucrt-x86_64-gcc), and gcc/g++ must be on PATH.")
  endif()

  list(APPEND _go_impl_build_commands
    COMMAND "${CMAKE_COMMAND}" -E env
            CGO_ENABLED=1
            "CC=${GO_IMPL_MINGW_CC}"
            "CXX=${GO_IMPL_MINGW_CXX}"
            GOOS=windows
            GOARCH=amd64
            "${GO_EXECUTABLE}" build -buildmode=c-shared
            -o "${GO_IMPL_SHARED_LIB}" .)
elseif(APPLE)
  # Podspec passes -DGO_IMPL_OSX_ARCHS="$ARCHS" (space-separated). Fallback:
  # CMAKE_OSX_ARCHITECTURES, then host CPU.
  if(DEFINED GO_IMPL_OSX_ARCHS AND NOT "${GO_IMPL_OSX_ARCHS}" STREQUAL "")
    separate_arguments(_go_impl_osx_archs NATIVE_COMMAND "${GO_IMPL_OSX_ARCHS}")
  elseif(CMAKE_OSX_ARCHITECTURES)
    set(_go_impl_osx_archs ${CMAKE_OSX_ARCHITECTURES})
  elseif(CMAKE_HOST_SYSTEM_PROCESSOR MATCHES "arm64|aarch64")
    set(_go_impl_osx_archs arm64)
  else()
    set(_go_impl_osx_archs x86_64)
  endif()

  set(_go_impl_lipo_inputs)
  set(_go_impl_slice_headers)
  foreach(_arch IN LISTS _go_impl_osx_archs)
    if(_arch STREQUAL "arm64")
      set(_goarch arm64)
    elseif(_arch STREQUAL "x86_64")
      set(_goarch amd64)
    else()
      message(FATAL_ERROR "go_impl: unsupported macOS architecture: ${_arch}")
    endif()
    # 用 libgo_impl_<arch>.dylib，避免 -o *.dylib.<arch> 时头文件被写成 *.dylib.h
    set(_slice "${CMAKE_CURRENT_BINARY_DIR}/libgo_impl_${_arch}.dylib")
    set(_slice_h "${CMAKE_CURRENT_BINARY_DIR}/libgo_impl_${_arch}.h")
    list(APPEND _go_impl_build_commands
      COMMAND "${CMAKE_COMMAND}" -E env
              CGO_ENABLED=1
              GOOS=darwin
              GOARCH=${_goarch}
              "${GO_EXECUTABLE}" build -buildmode=c-shared
              -o "${_slice}" .)
    list(APPEND _go_impl_lipo_inputs "${_slice}")
    list(APPEND _go_impl_slice_headers "${_slice_h}")
  endforeach()

  list(LENGTH _go_impl_lipo_inputs _go_impl_arch_count)
  if(_go_impl_arch_count EQUAL 1)
    list(APPEND _go_impl_build_commands
      COMMAND "${CMAKE_COMMAND}" -E copy "${_go_impl_lipo_inputs}" "${GO_IMPL_SHARED_LIB}"
      COMMAND "${CMAKE_COMMAND}" -E copy "${_go_impl_slice_headers}" "${GO_IMPL_SHARED_HEADER}"
      COMMAND "${CMAKE_COMMAND}" -E rm -f ${_go_impl_lipo_inputs} ${_go_impl_slice_headers})
  else()
    list(GET _go_impl_slice_headers 0 _go_impl_first_header)
    list(APPEND _go_impl_build_commands
      COMMAND lipo -create -output "${GO_IMPL_SHARED_LIB}" ${_go_impl_lipo_inputs}
      COMMAND "${CMAKE_COMMAND}" -E copy "${_go_impl_first_header}" "${GO_IMPL_SHARED_HEADER}"
      COMMAND "${CMAKE_COMMAND}" -E rm -f ${_go_impl_lipo_inputs} ${_go_impl_slice_headers})
  endif()
  # slice 的 LC_ID_DYLIB 带架构后缀；统一成最终产物名（podspec 还会改成 framework id）
  list(APPEND _go_impl_build_commands
    COMMAND install_name_tool -id "@rpath/libgo_impl.dylib" "${GO_IMPL_SHARED_LIB}")
else()
  list(APPEND _go_impl_build_commands
    COMMAND "${CMAKE_COMMAND}" -E env CGO_ENABLED=1
            "${GO_EXECUTABLE}" build -buildmode=c-shared
            -o "${GO_IMPL_SHARED_LIB}" .)
endif()

add_custom_target(
  go_impl_go
  ALL
  ${_go_impl_build_commands}
  BYPRODUCTS "${GO_IMPL_SHARED_LIB}" "${GO_IMPL_SHARED_HEADER}"
  WORKING_DIRECTORY "${GO_IMPL_GO_DIR}"
  COMMENT "Building Go go_impl shared library"
  VERBATIM)

add_library(go_impl SHARED IMPORTED GLOBAL)
set_target_properties(go_impl PROPERTIES IMPORTED_LOCATION "${GO_IMPL_SHARED_LIB}")
add_dependencies(go_impl go_impl_go)

if(ANDROID)
  # Support Android 15 16k page size
  set_target_properties(go_impl PROPERTIES IMPORTED_LINK_INTERFACE_LANGUAGES C)
endif()
