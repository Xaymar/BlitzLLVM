# Copyright (C) 2019-2025 Michael Fabian 'Xaymar' Dirks
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

# This is a self-contained toolchain file that sets up everything necessary to compile with LLVM/Clang.

cmake_minimum_required(VERSION 3.30...4.0)
include_guard(GLOBAL)
list(APPEND CMAKE_MESSAGE_INDENT "[LLVM] ")

if(CMAKE_C_COMPILER OR CMAKE_CXX_COMPILER)
	return()
endif()

# Try and figure out what processor we need to get binaries for.
set(LLVM_VERSION "19.1.7")
if(CMAKE_HOST_SYSTEM_NAME MATCHES "[Ww]indows")
	set(_OS "windows")
	string(TOLOWER "$ENV{PROCESSOR_ARCHITECTURE}" _ARCH)
	if(_ARCH MATCHES "(amd64)|(AMD64)")
		set(_FILE_NAME "LLVM-${LLVM_VERSION}-win64")
	elseif(_ARCH MATCHES "(x86)|(X86)")
		set(_FILE_NAME "LLVM-${LLVM_VERSION}-win32")
	else()
		set(_FILE_NAME "LLVM-${LLVM_VERSION}-woa64")
	endif()
	set(_FILE_EXT "exe")
elseif(CMAKE_HOST_SYSTEM_NAME MATCHES "[Dd]arwin")
	set(_OS "macos")
	execute_process(
		COMMAND "uname -m"
		OUTPUT_VARIABLE _ARCH
		OUTPUT_STRIP_TRAILING_WHITESPACE
		RESULT_VARIABLE _RES
	)
	if(_ARCH MATCHES "(x86)|(X86)|(amd64)|(AMD64)")
		set(_FILE_NAME "LLVM-${LLVM_VERSION}-MacOS-X64")
	else()
		set(_FILE_NAME "LLVM-${LLVM_VERSION}-MacOS-ARM64")
	endif()
	set(_FILE_EXT "tar.xz")
elseif(CMAKE_HOST_SYSTEM_NAME MATCHES "[Oo]pen[Bb][Ss][Dd]")
	set(_OS "openbsd")
	execute_process(
		COMMAND "arch"
		OUTPUT_VARIABLE _ARCH
		OUTPUT_STRIP_TRAILING_WHITESPACE
	)
	set(_FILE_EXT "tar.xz")
	if(_ARCH MATCHES "(x86)|(X86)|(amd64)|(AMD64)")
		set(_FILE_NAME "LLVM-${LLVM_VERSION}-Linux-X64")
	else()
		set(_FILE_NAME "LLVM-${LLVM_VERSION}-Linux-ARM64")
	endif()
else()
	set(_OS "linux")
	execute_process(
		COMMAND "uname -p"
		OUTPUT_VARIABLE _ARCH
		OUTPUT_STRIP_TRAILING_WHITESPACE
		RESULT_VARIABLE _RES
	)
	if(_RES EQUAL 0)
		execute_process(
			COMMAND "uname -m"
			OUTPUT_VARIABLE _ARCH
			OUTPUT_STRIP_TRAILING_WHITESPACE
			RESULT_VARIABLE _RES
		)
	endif()
	set(_FILE_EXT "tar.xz")
	if(_ARCH MATCHES "(x86)|(X86)|(amd64)|(AMD64)")
		set(_FILE_NAME "LLVM-${LLVM_VERSION}-Linux-X64")
	else()
		set(_FILE_NAME "LLVM-${LLVM_VERSION}-Linux-ARM64")
	endif()
endif()
set(LLVM_DIR "${CMAKE_SOURCE_DIR}/extra/llvm-${LLVM_VERSION}-${_OS}-${_ARCH}")

foreach(_T IN ITEMS LLVM_VERSION LLVM_VERSION_INSTALLED LLVM_DIR LLVM_AR LLVM_LD LLVM_RANLIB LLVM_OBJCOPY LLVM_OBJDUMP LLVM_STRIP LLVM_CLANG LLVM_CLANGPP)
	message(STATUS "${_T}=${${_T}}")
endforeach()

function(validator_llvm_bin _var _item)
	message(STATUS "${_var} ${_item}")
	if(NOT IS_EXECUTABLE "${_item}")
		set("${_var}" FALSE PARENT_SCOPE)
		return()
	endif()
	execute_process(
		COMMAND "${_item}" --version
		OUTPUT_VARIABLE _OUT
		RESULT_VARIABLE _RES
		OUTPUT_STRIP_TRAILING_WHITESPACE
	)
	message(STATUS "${_OUT} ${_RES}")
	if(NOT _RES EQUAL 0)
		set("${_var}" FALSE PARENT_SCOPE)
		return()
	endif()
	if(_OUT VERSION_LESS LLVM_VERSION)
		set("${_var}" FALSE PARENT_SCOPE)
		return()
	endif()
	set("${_var}" TRUE PARENT_SCOPE)
	set(LLVM_VERSION_INSTALLED "${_OUT}" PARENT_SCOPE)
endfunction()

macro(find_llvm)
	set(LLVM_FOUND "NOT-FOUND")
	# - AR
	find_program(
		LLVM_AR
		NAMES 
			llvm-ar
		HINTS
			"${LLVM_DIR}/bin"
		#VALIDATOR validator_llvm_bin
		NO_CACHE NO_DEFAULT_PATH NO_PACKAGE_ROOT_PATH NO_CMAKE_PATH NO_CMAKE_ENVIRONMENT_PATH NO_SYSTEM_ENVIRONMENT_PATH NO_CMAKE_INSTALL_PREFIX NO_CMAKE_FIND_ROOT_PATH
	)
	# - Library Randomizer
	find_program(
		LLVM_RANLIB
		NAMES
			llvm-ranlib
		HINTS
			"${LLVM_DIR}/bin"
		#VALIDATOR validator_llvm_bin
		NO_CACHE NO_DEFAULT_PATH NO_PACKAGE_ROOT_PATH NO_CMAKE_PATH NO_CMAKE_ENVIRONMENT_PATH NO_SYSTEM_ENVIRONMENT_PATH NO_CMAKE_INSTALL_PREFIX NO_CMAKE_FIND_ROOT_PATH
	)
	# - Linker
	find_program(
		LLVM_LD
		NAMES
			ld.lld
		HINTS
			"${LLVM_DIR}/bin"
		#VALIDATOR validator_llvm_bin
		NO_CACHE NO_DEFAULT_PATH NO_PACKAGE_ROOT_PATH NO_CMAKE_PATH NO_CMAKE_ENVIRONMENT_PATH NO_SYSTEM_ENVIRONMENT_PATH NO_CMAKE_INSTALL_PREFIX NO_CMAKE_FIND_ROOT_PATH
	)
	# - Object Copy
	find_program(
		LLVM_OBJCOPY
		NAMES
			llvm-objcopy
		HINTS
			"${LLVM_DIR}/bin"
		#VALIDATOR validator_llvm_bin
		NO_CACHE NO_DEFAULT_PATH NO_PACKAGE_ROOT_PATH NO_CMAKE_PATH NO_CMAKE_ENVIRONMENT_PATH NO_SYSTEM_ENVIRONMENT_PATH NO_CMAKE_INSTALL_PREFIX NO_CMAKE_FIND_ROOT_PATH
	)
	# - Object Dump
	find_program(
		LLVM_OBJDUMP
		NAMES
			llvm-objdump
		HINTS
			"${LLVM_DIR}/bin"
		#VALIDATOR validator_llvm_bin
		NO_CACHE NO_DEFAULT_PATH NO_PACKAGE_ROOT_PATH NO_CMAKE_PATH NO_CMAKE_ENVIRONMENT_PATH NO_SYSTEM_ENVIRONMENT_PATH NO_CMAKE_INSTALL_PREFIX NO_CMAKE_FIND_ROOT_PATH
	)
	# - Strip Debug Info
	find_program(
		LLVM_STRIP
		NAMES
			llvm-strip
		HINTS
			"${LLVM_DIR}/bin"
		#VALIDATOR validator_llvm_bin
		NO_CACHE NO_DEFAULT_PATH NO_PACKAGE_ROOT_PATH NO_CMAKE_PATH NO_CMAKE_ENVIRONMENT_PATH NO_SYSTEM_ENVIRONMENT_PATH NO_CMAKE_INSTALL_PREFIX NO_CMAKE_FIND_ROOT_PATH
	)
	# - C Compiler
	find_program(
		LLVM_CLANG
		NAMES
			clang
		HINTS
			"${LLVM_DIR}/bin"
		#VALIDATOR validator_llvm_bin
		NO_CACHE NO_DEFAULT_PATH NO_PACKAGE_ROOT_PATH NO_CMAKE_PATH NO_CMAKE_ENVIRONMENT_PATH NO_SYSTEM_ENVIRONMENT_PATH NO_CMAKE_INSTALL_PREFIX NO_CMAKE_FIND_ROOT_PATH
	)
	# - C++ Compiler
	find_program(
		LLVM_CLANGPP
		NAMES
			clang++
		HINTS
			"${LLVM_DIR}/bin"
		#VALIDATOR validator_llvm_bin
		NO_CACHE NO_DEFAULT_PATH NO_PACKAGE_ROOT_PATH NO_CMAKE_PATH NO_CMAKE_ENVIRONMENT_PATH NO_SYSTEM_ENVIRONMENT_PATH NO_CMAKE_INSTALL_PREFIX NO_CMAKE_FIND_ROOT_PATH
	)

	set(LLVM_FOUND TRUE)
	foreach(_TEST IN ITEMS 
		"LLVM_AR"
		"LLVM_LD"
		"LLVM_RANLIB"
		"LLVM_OBJCOPY"
		"LLVM_OBJDUMP"
		"LLVM_STRIP"
		"LLVM_CLANG"
		"LLVM_CLANGPP")
		message(STATUS "${_TEST}=${${_TEST}}")
		if(NOT IS_EXECUTABLE ${${_TEST}})
			set(LLVM_FOUND FALSE)
			foreach(_TEST IN ITEMS 
				"LLVM_AR"
				"LLVM_LD"
				"LLVM_RANLIB"
				"LLVM_OBJCOPY"
				"LLVM_OBJDUMP"
				"LLVM_STRIP"
				"LLVM_CLANG"
				"LLVM_CLANGPP")
				unset(${_TEST})
			endforeach()
		endif()
	endforeach()
endmacro()

# Try and find an existing LLVM installation.
find_llvm()
foreach(_T IN ITEMS LLVM_VERSION LLVM_VERSION_INSTALLED LLVM_DIR LLVM_AR LLVM_LD LLVM_RANLIB LLVM_OBJCOPY LLVM_OBJDUMP LLVM_STRIP LLVM_CLANG LLVM_CLANGPP)
	message(STATUS "${_T}=${${_T}}")
endforeach()
if(LLVM_FOUND)
	message(STATUS "Found v${LLVM_VERSION_INSTALLED}.")
elseif(LLVM_VERSION_INSTALLED AND LLVM_VERSION_INSTALLED VERSION_LESS LLVM_VERSION)
	message(STATUS "Found outdated v${LLVM_VERSION_INSTALLED}.")
elseif(NOT LLVM_FOUND AND NOT LLVM_VERSION_INSTALLED)
	message(STATUS "No installed LLVM found.")
endif()

if(NOT LLVM_FOUND)
	# It isn't up to date or doesn't exist, so try to download the latest version.

	# Download the ideal version.
	message(STATUS "Downloading LLVM v${LLVM_VERSION}...")
	file(DOWNLOAD
		"https://github.com/llvm/llvm-project/releases/download/llvmorg-${LLVM_VERSION}/${_FILE_NAME}.${_FILE_EXT}"
		"${LLVM_DIR}.${_FILE_EXT}"
		SHOW_PROGRESS
	)

	# Extract it.
	message(STATUS "Extracting...")
	file(ARCHIVE_EXTRACT
		INPUT "${LLVM_DIR}.${_FILE_EXT}"
		DESTINATION "${LLVM_DIR}/"
	)

endif()



# set(CMAKE_C_COMPILER_AR "${CMAKE_AR}" CACHE STRING "" FORCE)
# #set(CMAKE_C_COMPILER_CLANG_SCAN_DEPS "NOT-FOUND" CACHE STRING "" FORCE)
# set(CMAKE_C_COMPILER_RANLIB "${CMAKE_RANLIB}" CACHE STRING "" FORCE)
# set(CMAKE_C_LINKER "${CMAKE_LINKER}" CACHE STRING "" FORCE)
# set(CMAKE_C_LINKER_ID "LDD" CACHE STRING "" FORCE)
# set(CMAKE_C_LINKER_FRONTEND_VARIANT "LLD" CACHE STRING "" FORCE)
# set(CMAKE_CXX_COMPILER_AR "${CMAKE_AR}" CACHE STRING "" FORCE)
# #set(CMAKE_CXX_COMPILER_CLANG_SCAN_DEPS "NOT-FOUND" CACHE STRING "" FORCE)
# set(CMAKE_CXX_SCAN_FOR_MODULES OFF CACHE BOOL "" FORCE)
# set(CMAKE_CXX_COMPILER_RANLIB "${CMAKE_RANLIB}" CACHE STRING "" FORCE)
# set(CMAKE_CXX_LINKER "${CMAKE_C_LINKER}" CACHE STRING "" FORCE)
# set(CMAKE_CXX_LINKER_ID "LLD" CACHE STRING "" FORCE)
# set(CMAKE_CXX_LINKER_FRONTEND_VARIANT "LLD" CACHE STRING "" FORCE)
# # - Assembly Compiler
# set(CMAKE_ASM_COMPILER "${CMAKE_C_COMPILER}" CACHE STRING "" FORCE)
# set(CMAKE_ASM_COMPILER_AR "${CMAKE_AR}" CACHE STRING "" FORCE)
# #set(CMAKE_ASM_COMPILER_CLANG_SCAN_DEPS "NOT-FOUND" CACHE STRING "" FORCE)
# set(CMAKE_ASM_COMPILER_RANLIB "${CMAKE_RANLIB}" CACHE STRING "" FORCE)
# set(CMAKE_ASM_LINKER "${CMAKE_C_LINKER}" CACHE STRING "" FORCE)
# set(CMAKE_ASM_LINKER_ID "LLD" CACHE STRING "" FORCE)
# set(CMAKE_ASM_LINKER_FRONTEND_VARIANT "LLD" CACHE STRING "" FORCE)
# #mark_as_advanced(CLANG_C_COMPILER CLANG_CPP_COMPILER CLANG__AR CLANG__LD_LDD)
# set(CMAKE_EXE_LINKER_FLAGS_INIT "-fuse-ld=\"${CMAKE_C_LINKER}\"")
# set(CMAKE_STATIC_LINKER_FLAGS_INIT "-fuse-ld=\"${CMAKE_C_LINKER}\"")
# set(CMAKE_MODULE_LINKER_FLAGS_INIT "-fuse-ld=\"${CMAKE_C_LINKER}\"")
# set(CMAKE_SHARED_LINKER_FLAGS_INIT "-fuse-ld=\"${CMAKE_C_LINKER}\"")

# execute_process(
# 	COMMAND "${CMAKE_C_COMPILER}" "--version"
# 	OUTPUT_VARIABLE _VERSION_INSTALLED
# 	OUTPUT_STRIP_TRAILING_WHITESPACE
# )
# string(REGEX MATCH "[0-9]+\.[0-9]+\.[0-9]+" _VERSION_INSTALLED "${LLVM_VERSION_INSTALLED}")
# message(STATUS "v${LLVM_VERSION_INSTALLED}")
# list(POP_BACK CMAKE_MESSAGE_INDENT)
