cmake_minimum_required(VERSION 3.0.2)
project(CodeCompiler)

# Configuration

## Dependencies
# LLVM
#find_package(LLVM REQUIRED CONFIG)
#llvm_map_components_to_libnames(llvm_libs support core irreader)

# Boost
#SET(BOOST_ROOT "" CACHE PATH "Path to Boost")
#SET(Boost_USE_STATIC_LIBS ON)
#find_package(Boost REQUIRED COMPONENTS program_options)

## Version
INCLUDE("CMakeVersion.txt")

## Compiling
# Source Files
SET(SOURCE
	"source/main.cpp"
	"source/lexer.hpp"
	"source/lexer.cpp"
	"source/ast/ast.hpp"
	"source/ast/ast.cpp"
	"source/ast/arithmetic.hpp"
	"source/ast/arithmetic.cpp"
	"source/ast/function.hpp"
	"source/ast/function.cpp"
	"source/ast/value.hpp"
	"source/ast/value.cpp"
	"source/parser.hpp"
	"source/parser.cpp"
	"source/compiler.hpp"
	"source/compiler.cpp"
)
SET(DATA
	"CMakeVersion.txt"
)

# Source Grouping
SOURCE_GROUP(TREE ${PROJECT_SOURCE_DIR}/source PREFIX Source FILES ${SOURCE})

# Definitions
ADD_DEFINITIONS(
	${LLVM_DEFINITIONS}
)

# Directories
INCLUDE_DIRECTORIES(
	"${PROJECT_SOURCE_DIR}/source"
	"${PROJECT_BINARY_DIR}"
	${LLVM_INCLUDE_DIRS}
	${Boost_INCLUDE_DIRS}
)
LINK_DIRECTORIES(
	${LLVM_LIBRARY_DIRS}
	${Boost_LIBRARY_DIRS}
)

# Building
ADD_EXECUTABLE(cc
	${SOURCE}
	${DATA}
)

# Linking
TARGET_LINK_LIBRARIES(cc
	${Boost_LIBRARIES}
	${llvm_libs}
)
