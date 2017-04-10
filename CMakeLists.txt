cmake_minimum_required(VERSION 2.8.12)
project(BlitzLLVM)

# Version
INCLUDE("CMakeVersion.txt")

SET(DEPENDENCY_LLVM "${PROJECT_SOURCE_DIR}/thirdparty/llvm" CACHE PATH "Path to LLVM source code")

# Source Files
SET(BlitzLLVM_SOURCE
	"source/main.cpp"
)

INCLUDE_DIRECTORIES(
	"${CMAKE_SOURCE_DIR}"
	"${PROJECT_SOURCE_DIR}"
	"${PROJECT_SOURCE_DIR}/source"
	"${DEPENDENCY_LLVM}/include"
	"${PROJECT_BINARY_DIR}"
)

add_executable(BlitzLLVM ${BlitzLLVM_SOURCE})
