# Copyright (C) 2023-2024 Michael Fabian 'Xaymar' Dirks
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
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

cmake_minimum_required(VERSION 3.30...4.0)
include_guard(GLOBAL)

if((CMAKE_GENERATOR STREQUAL "Ninja") OR (CMAKE_GENERATOR STREQUAL "Ninja Multi-Config"))
	include("${CMAKE_CURRENT_LIST_DIR}/../generators/ninja.cmake")
endif()

list(APPEND CMAKE_MESSAGE_INDENT "[LLVM-ARM] ")
set(_VERSION "18.1.3")
set(_FILE "llvm-arm-${CMAKE_HOST_SYSTEM_NAME}-${CMAKE_HOST_SYSTEM_PROCESSOR}")
if(CMAKE_HOST_SYSTEM_NAME MATCHES "Windows") # Windows
	set(_FILENAME "LLVM-ET-Arm-${_VERSION}-Windows-x86_64")
	set(_FILEEXT "zip")
elseif(CMAKE_HOST_SYSTEM_NAME MATCHES "Darwin") # Darwin
	set(_FILENAME "LLVM-ET-Arm-${_VERSION}-Darwin")
	set(_FILEEXT "dmg")
else() # Generic Unix-like
	set(_FILEEXT "tar.xz")
	if(CMAKE_HOST_SYSTEM_PROCESSOR MATCHES "(x86)|(X86)|(amd64)|(AMD64)")
		set(_FILENAME "LLVM-ET-Arm-${_VERSION}-Linux-x86_64")
	else()
		set(_FILENAME "LLVM-ET-Arm-${_VERSION}-Linux-AArch64")
	endif()
endif()

# Very hacky way to get CMake to behave like a normal makefile generator, instead of a mentally challenged makefile generator.
if(TRUE) # Check if we've already installed one of these, 
	if(WIN32)
		set(TEMP "$ENV{TEMP}")
	else()
		set(TEMP "$ENV{TMPDIR}")
	endif()
	set(_PATH "${TEMP}/cmake/llvm-arm/${_VERSION}")
	if(EXISTS "${_PATH}")
		file(READ "${_PATH}" _DIR)
		if (NOT EXISTS "${_DIR}")
			file(REMOVE "${_PATH}")
			unset(_DIR)
		endif()
	endif()
endif()

if((NOT _DIR) OR (EXISTS "${PROJECT_BINARY_DIR}/toolchain/${_FILE}.version"))
	# Check if the version is what we expect.
	if(EXISTS "${PROJECT_BINARY_DIR}/toolchain/${_FILE}.version")
		file(READ "${PROJECT_BINARY_DIR}/toolchain/${_FILE}.version" _VERSION_STORED)
	endif()
	if((NOT _VERSION_STORED) OR (_VERSION_STORED VERSION_LESS _VERSION))
		message(STATUS "Updating... (${_VERSION_STORED} < ${_VERSION})")


		# Download the appropriate package from https://github.com/ARM-software/LLVM-embedded-toolchain-for-Arm
		#- Grab the latest hash from the remote.
		set(_HASH_FILE "${PROJECT_BINARY_DIR}/toolchain/${_FILE}.sha256")
		file(DOWNLOAD
			"https://github.com/ARM-software/LLVM-embedded-toolchain-for-Arm/releases/download/release-${_VERSION}/${_FILENAME}.${_FILEEXT}.sha256"
			"${_HASH_FILE}"
		)
		file(READ "${_HASH_FILE}" _DOWNLOAD_SHA256)
		string(REGEX MATCH "[0-9a-fA-F]+" _DOWNLOAD_SHA256 "${_DOWNLOAD_SHA256}")
		file(REMOVE "${_HASH_FILE}")

		#- Download the latest toolchain
		set(_PACKAGE_FILE "${PROJECT_BINARY_DIR}/toolchain/${_FILE}.${_FILEEXT}")
		file(DOWNLOAD
			"https://github.com/ARM-software/LLVM-embedded-toolchain-for-Arm/releases/download/release-${_VERSION}/${_FILENAME}.${_FILEEXT}"
			"${_PACKAGE_FILE}"
			EXPECTED_HASH SHA256=${_DOWNLOAD_SHA256}
		)

		#- Extract the contents
		file(ARCHIVE_EXTRACT 
			INPUT "${_PACKAGE_FILE}"
			DESTINATION "${PROJECT_BINARY_DIR}/toolchain/"
		)
		#file(REMOVE "${_PACKAGE_FILE}")

		file(WRITE "${PROJECT_BINARY_DIR}/toolchain/${_FILE}.version" "${_VERSION}")
	endif()

	# Update the virtual link
	file(WRITE "${_PATH}" "${PROJECT_BINARY_DIR}/toolchain/${_FILENAME}/")

	set(_LLVM_TOOLCHAIN "${PROJECT_BINARY_DIR}/toolchain/${_FILENAME}/")
else()
	set(_LLVM_TOOLCHAIN "${_DIR}")
endif()

list(APPEND CMAKE_PREFIX_PATH
	"${_LLVM_TOOLCHAIN}/bin"
	"${_LLVM_TOOLCHAIN}"
)
# Find necessary programs.
# - AR
find_program(
	CMAKE_AR
	NAMES
		llvm-ar
	PATHS
		"${_LLVM_TOOLCHAIN}/bin"
	NO_DEFAULT_PATH NO_PACKAGE_ROOT_PATH NO_CMAKE_PATH NO_CMAKE_ENVIRONMENT_PATH NO_SYSTEM_ENVIRONMENT_PATH NO_CMAKE_INSTALL_PREFIX NO_CMAKE_FIND_ROOT_PATH
)
# - Library Randomizer
find_program(
	CMAKE_RANLIB
	NAMES
		llvm-ranlib
	PATHS
		"${_LLVM_TOOLCHAIN}/bin"
	NO_DEFAULT_PATH NO_PACKAGE_ROOT_PATH NO_CMAKE_PATH NO_CMAKE_ENVIRONMENT_PATH NO_SYSTEM_ENVIRONMENT_PATH NO_CMAKE_INSTALL_PREFIX NO_CMAKE_FIND_ROOT_PATH
)
# - Linker
find_program(
	CMAKE_LINKER
	NAMES
		ld.lld
	PATHS
		"${_LLVM_TOOLCHAIN}/bin"
	NO_DEFAULT_PATH NO_PACKAGE_ROOT_PATH NO_CMAKE_PATH NO_CMAKE_ENVIRONMENT_PATH NO_SYSTEM_ENVIRONMENT_PATH NO_CMAKE_INSTALL_PREFIX NO_CMAKE_FIND_ROOT_PATH
)
# - Object Copy
find_program(
	CMAKE_OBJCOPY
	NAMES
		llvm-objcopy
	PATHS
		"${_LLVM_TOOLCHAIN}/bin"
	NO_DEFAULT_PATH NO_PACKAGE_ROOT_PATH NO_CMAKE_PATH NO_CMAKE_ENVIRONMENT_PATH NO_SYSTEM_ENVIRONMENT_PATH NO_CMAKE_INSTALL_PREFIX NO_CMAKE_FIND_ROOT_PATH
)
# - Object Dump
find_program(
	CMAKE_OBJDUMP
	NAMES
		llvm-objdump
	PATHS
		"${_LLVM_TOOLCHAIN}/bin"
	NO_DEFAULT_PATH NO_PACKAGE_ROOT_PATH NO_CMAKE_PATH NO_CMAKE_ENVIRONMENT_PATH NO_SYSTEM_ENVIRONMENT_PATH NO_CMAKE_INSTALL_PREFIX NO_CMAKE_FIND_ROOT_PATH
)
# - Strip Debug Info
find_program(
	CMAKE_STRIP
	NAMES
		llvm-strip
	PATHS
		"${_LLVM_TOOLCHAIN}/bin"
	NO_DEFAULT_PATH NO_PACKAGE_ROOT_PATH NO_CMAKE_PATH NO_CMAKE_ENVIRONMENT_PATH NO_SYSTEM_ENVIRONMENT_PATH NO_CMAKE_INSTALL_PREFIX NO_CMAKE_FIND_ROOT_PATH
)
# - C Compiler
find_program(
	CMAKE_C_COMPILER
	NAMES
		clang
		clang++
		clang-cpp
	PATHS
		"${_LLVM_TOOLCHAIN}/bin"
	NO_DEFAULT_PATH NO_PACKAGE_ROOT_PATH NO_CMAKE_PATH NO_CMAKE_ENVIRONMENT_PATH NO_SYSTEM_ENVIRONMENT_PATH NO_CMAKE_INSTALL_PREFIX NO_CMAKE_FIND_ROOT_PATH
)
set(CMAKE_C_COMPILER_AR "${CMAKE_AR}" CACHE STRING "" FORCE)
#set(CMAKE_C_COMPILER_CLANG_SCAN_DEPS "NOT-FOUND" CACHE STRING "" FORCE)
set(CMAKE_C_COMPILER_RANLIB "${CMAKE_RANLIB}" CACHE STRING "" FORCE)
set(CMAKE_C_LINKER "${CMAKE_LINKER}" CACHE STRING "" FORCE)
set(CMAKE_C_LINKER_ID "LDD" CACHE STRING "" FORCE)
set(CMAKE_C_LINKER_FRONTEND_VARIANT "LLD" CACHE STRING "" FORCE)
# - C++ Compiler
find_program(
	CMAKE_CXX_COMPILER
	NAMES
		clang++
		clang-cpp
		clang
	PATHS
		"${_LLVM_TOOLCHAIN}/bin"
	NO_DEFAULT_PATH NO_PACKAGE_ROOT_PATH NO_CMAKE_PATH NO_CMAKE_ENVIRONMENT_PATH NO_SYSTEM_ENVIRONMENT_PATH NO_CMAKE_INSTALL_PREFIX NO_CMAKE_FIND_ROOT_PATH
)
set(CMAKE_CXX_COMPILER_AR "${CMAKE_AR}" CACHE STRING "" FORCE)
#set(CMAKE_CXX_COMPILER_CLANG_SCAN_DEPS "NOT-FOUND" CACHE STRING "" FORCE)
set(CMAKE_CXX_SCAN_FOR_MODULES OFF CACHE BOOL "" FORCE)
set(CMAKE_CXX_COMPILER_RANLIB "${CMAKE_RANLIB}" CACHE STRING "" FORCE)
set(CMAKE_CXX_LINKER "${CMAKE_C_LINKER}" CACHE STRING "" FORCE)
set(CMAKE_CXX_LINKER_ID "LLD" CACHE STRING "" FORCE)
set(CMAKE_CXX_LINKER_FRONTEND_VARIANT "LLD" CACHE STRING "" FORCE)
# - Assembly Compiler
set(CMAKE_ASM_COMPILER "${CMAKE_C_COMPILER}" CACHE STRING "" FORCE)
set(CMAKE_ASM_COMPILER_AR "${CMAKE_AR}" CACHE STRING "" FORCE)
#set(CMAKE_ASM_COMPILER_CLANG_SCAN_DEPS "NOT-FOUND" CACHE STRING "" FORCE)
set(CMAKE_ASM_COMPILER_RANLIB "${CMAKE_RANLIB}" CACHE STRING "" FORCE)
set(CMAKE_ASM_LINKER "${CMAKE_C_LINKER}" CACHE STRING "" FORCE)
set(CMAKE_ASM_LINKER_ID "LLD" CACHE STRING "" FORCE)
set(CMAKE_ASM_LINKER_FRONTEND_VARIANT "LLD" CACHE STRING "" FORCE)

#mark_as_advanced(CLANG_C_COMPILER CLANG_CPP_COMPILER CLANG__AR CLANG__LD_LDD)
set(CMAKE_EXE_LINKER_FLAGS_INIT "-fuse-ld=\"${CMAKE_C_LINKER}\"")
set(CMAKE_STATIC_LINKER_FLAGS_INIT "-fuse-ld=\"${CMAKE_C_LINKER}\"")
set(CMAKE_MODULE_LINKER_FLAGS_INIT "-fuse-ld=\"${CMAKE_C_LINKER}\"")
set(CMAKE_SHARED_LINKER_FLAGS_INIT "-fuse-ld=\"${CMAKE_C_LINKER}\"")

execute_process(
	COMMAND "${CMAKE_C_COMPILER}" "--version"
	OUTPUT_VARIABLE _VERSION_INSTALLED
	OUTPUT_STRIP_TRAILING_WHITESPACE
)
string(REGEX MATCH "[0-9]+\.[0-9]+\.[0-9]+" _VERSION_INSTALLED "${_VERSION_INSTALLED}")
message(STATUS "v${_VERSION_INSTALLED}")
list(POP_BACK CMAKE_MESSAGE_INDENT)
