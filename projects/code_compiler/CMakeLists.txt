cmake_minimum_required(VERSION 2.8.12)
project(CodeCompiler)

# Configuration
SET(THIRDPARTY_LLVM "${CMAKE_SOURCE_DIR}/thirdparty/llvm" CACHE PATH "Path to LLVM source code")

## Dependencies
# LLVM
SET(LLVM_BUILD_TOOLS OFF)
SET(LLVM_BUILD_EXAMPLES OFF)
SET(LLVM_BUILD_TESTS OFF)
SET(LLVM_INCLUDE_TESTS OFF)
SET(BUILD_SHARED_LIBS OFF)
SET(LLVM_BUILD_LLVM_DYLIB OFF)
ADD_SUBDIRECTORY("${DEPENDENCY_LLVM}")

## Version
INCLUDE("CMakeVersion.txt")

## Compiling
# Source Files
SET(SOURCE
	"source/main.cpp"
)
SET(DATA
	"templates/version.h"
)

# Include Directories
INCLUDE_DIRECTORIES(
	"${CMAKE_SOURCE_DIR}"
	"${PROJECT_SOURCE_DIR}"
	"${PROJECT_SOURCE_DIR}/source"
	"${THIRDPARTY_LLVM}/include"
	"${PROJECT_BINARY_DIR}"
)

# Building
add_executable(${PROJECT_NAME} ${SOURCE})

# Linking
TARGET_LINK_LIBRARIES(${PROJECT_NAME}
	LLVM
)
