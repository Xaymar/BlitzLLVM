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

# This is a (mostly) self-contained toolchain file that sets up everything necessary to compile with LLVM/Clang.
# cmake --fresh -C cmake/generators/ninja.cmake  --preset windows-x64-llvm

cmake_minimum_required(VERSION 3.30...4.0)
include_guard(GLOBAL)
list(APPEND CMAKE_MESSAGE_INDENT "[LLVM] ")

# Necessary for propagation into the try_compile CMake subprocesses. It's unclear why this is not the default behavior.
foreach(_T IN ITEMS CMAKE_AR CMAKE_RANLIB CMAKE_LINKER CMAKE_C_COMPILER CMAKE_C_COMPILER_AR CMAKE_C_COMPILER_RANLIB CMAKE_C_COMPILER_LINKER CMAKE_C_COMPILER_LINKER_ID CMAKE_C_COMPILER_LINKER_VERSION CMAKE_CXX_COMPILER CMAKE_CXX_COMPILER_AR CMAKE_CXX_COMPILER_RANLIB CMAKE_CXX_COMPILER_LINKER CMAKE_CXX_COMPILER_LINKER_ID CMAKE_CXX_COMPILER_LINKER_VERSION CMAKE_ASM_COMPILER CMAKE_ASM_COMPILER_AR CMAKE_ASM_COMPILER_RANLIB CMAKE_ASM_COMPILER_LINKER CMAKE_ASM_COMPILER_LINKER_ID CMAKE_ASM_COMPILER_LINKER_VERSION CMAKE_RC_COMPILER CMAKE_RC_COMPILER_AR CMAKE_RC_COMPILER_RANLIB CMAKE_RC_COMPILER_LINKER CMAKE_RC_COMPILER_LINKER_ID CMAKE_RC_COMPILER_LINKER_VERSION)
	if(DEFINED ENV{${_T}})
		set(${_T} "$ENV{${_T}}")
	endif()
endforeach()

if(
	(NOT IS_EXECUTABLE CMAKE_C_COMPILER) OR
	(NOT IS_EXECUTABLE CMAKE_C_COMPILER_AR) OR
	(NOT IS_EXECUTABLE CMAKE_C_COMPILER_RANLIB) OR
	(NOT IS_EXECUTABLE CMAKE_C_COMPILER_LINKER) OR
	(NOT IS_EXECUTABLE CMAKE_CXX_COMPILER) OR
	(NOT IS_EXECUTABLE CMAKE_CXX_COMPILER_AR) OR
	(NOT IS_EXECUTABLE CMAKE_CXX_COMPILER_RANLIB) OR
	(NOT IS_EXECUTABLE CMAKE_CXX_COMPILER_LINKER) OR
	(NOT IS_EXECUTABLE CMAKE_LINKER) OR
	(NOT IS_EXECUTABLE CMAKE_RANLIB) OR
	(NOT IS_EXECUTABLE CMAKE_AR)
)
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

		#Computer\HKEY_CURRENT_USER\SOFTWARE\7-Zip\Path64
		cmake_host_system_information(
			RESULT 7ZIP_DIR
			QUERY WINDOWS_REGISTRY "HKCU/SOFTWARE/7-Zip" VALUE "Path64"
			VIEW HOST
		)
		find_program(7ZIP_BIN
			NAMES
				7z
				7za
			HINTS
				"${7ZIP_DIR}"
				"C:/Program Files/7-Zip"
				"C:/Program Files (x86)/7-Zip"
		)
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

	macro(find_llvm)
		set(LLVM_FOUND "FALSE")

		# - AR
		find_program(
			LLVM_AR
			NAMES
				llvm-ar
			PATHS
				"${LLVM_DIR}/bin/"
			NO_CACHE
		)

		# - Library Randomizer
		find_program(
			LLVM_RANLIB
			NAMES
				llvm-ranlib
			PATHS
				"${LLVM_DIR}/bin/"
			NO_CACHE
		)

		# - Linker
		if(_ARCH MATCHES "[xX]64")
			find_program(
				LLVM_LD
				NAMES
					ld64.lld
					ld.lld
				PATHS
					"${LLVM_DIR}/bin/"
				NO_CACHE
			)
		else()
			find_program(
				LLVM_LD
				NAMES
					ld.lld
				PATHS
					"${LLVM_DIR}/bin/"
				NO_CACHE
			)
		endif()

		# - Object Copy
		find_program(
			LLVM_OBJCOPY
			NAMES
				llvm-objcopy
			PATHS
				"${LLVM_DIR}/bin/"
			NO_CACHE
		)

		# - Object Dump
		find_program(
			LLVM_OBJDUMP
			NAMES
				llvm-objdump
			PATHS
				"${LLVM_DIR}/bin/"
			NO_CACHE
		)

		# - Strip Debug Info
		find_program(
			LLVM_STRIP
			NAMES
				llvm-strip
			PATHS
				"${LLVM_DIR}/bin/"
			NO_CACHE
		)

		# - C Compiler
		find_program(
			LLVM_CLANG
			NAMES
				clang
			PATHS
				"${LLVM_DIR}/bin/"
			NO_CACHE
		)

		# - C++ Compiler
		find_program(
			LLVM_CLANGPP
			NAMES
				clang++
			PATHS
				"${LLVM_DIR}/bin/"
			NO_CACHE
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
			if(NOT IS_EXECUTABLE ${${_TEST}})
				set(LLVM_FOUND FALSE)
				break()
			else()
				execute_process(
					COMMAND "${${_TEST}}" --version
					OUTPUT_VARIABLE ${_TEST}_VERSION
					RESULT_VARIABLE _RES
				)
				if(NOT _RES EQUAL 0)
					set(LLVM_FOUND FALSE)
					break()
				endif()

				string(REGEX MATCH "[1-9+]?[0-9+]\.[1-9+]?[0-9+]\.[1-9+]?[0-9+]\." "${_TEST}_VERSION" "${${_TEST}_VERSION}")
				string(REGEX REPLACE "[\r\n]+" "" "${_TEST}_VERSION" "${${_TEST}_VERSION}")
				if(${_TEST}_VERSION VERSION_LESS LLVM_VERSION)
					set(LLVM_FOUND FALSE)
				endif()
			endif()
		endforeach()

	#	foreach(_T IN ITEMS LLVM_VERSION LLVM_DIR LLVM_AR LLVM_LD LLVM_RANLIB LLVM_OBJCOPY LLVM_OBJDUMP LLVM_STRIP LLVM_CLANG LLVM_CLANGPP LLVM_AR_VERSION LLVM_LD_VERSION LLVM_RANLIB_VERSION LLVM_OBJCOPY_VERSION LLVM_OBJDUMP_VERSION LLVM_STRIP_VERSION LLVM_CLANG_VERSION LLVM_CLANGPP)
	#		message(STATUS "${_T}=${${_T}}")
	#	endforeach()
	endmacro()

	# Try and find an existing LLVM installation.
	find_llvm()
	if(LLVM_CLANG_VERSION AND LLVM_CLANG_VERSION VERSION_LESS LLVM_VERSION)
		message(STATUS "Found outdated v${LLVM_CLANG_VERSION}.")
	elseif(NOT LLVM_FOUND)
		message(STATUS "No installed LLVM found.")
	endif()

	if(NOT LLVM_FOUND OR (LLVM_CLANG_VERSION VERSION_LESS LLVM_VERSION))
		# It isn't up to date or doesn't exist, so try to download the latest version.
		if((_FILE_EXT MATCHES "exe") AND NOT 7ZIP_BIN)
			message(FATAL_ERROR "7-Zip is required to continue setting up LLVM. Please provide '7z.exe' in PATH or by installing the latest version from https://www.7-zip.org/.")
		endif()

		# Download the ideal version.
		if(NOT EXISTS "${LLVM_DIR}.${_FILE_EXT}")
			message(STATUS "Downloading LLVM v${LLVM_VERSION}...")
			file(DOWNLOAD
				"https://github.com/llvm/llvm-project/releases/download/llvmorg-${LLVM_VERSION}/${_FILE_NAME}.${_FILE_EXT}"
				"${LLVM_DIR}.${_FILE_EXT}"
				SHOW_PROGRESS
			)
		else()
			message(STATUS "Skipping download as file already exists.")
		endif()

		# Extract it.
		message(STATUS "Extracting...")
		if(_FILE_EXT MATCHES "exe")
			execute_process(
				COMMAND ${7ZIP_BIN} x -y -aoa "-o${LLVM_DIR}/" "${LLVM_DIR}.${_FILE_EXT}"
				COMMAND_ERROR_IS_FATAL ANY
				OUTPUT_QUIET
				ERROR_QUIET
			)
		else()
			file(ARCHIVE_EXTRACT
				INPUT "${LLVM_DIR}.${_FILE_EXT}"
				DESTINATION "${LLVM_DIR}/"
			)
		endif()

		# Delete the archive itself.
		message(STATUS "Cleaning...")
		file(REMOVE "${LLVM_DIR}.${_FILE_EXT}")

		# Final stuff
		#message(STATUS "Testing...")
		find_llvm()
	endif()

	if(LLVM_FOUND AND (LLVM_CLANG_VERSION VERSION_GREATER_EQUAL LLVM_VERSION))
		message(STATUS "Found v${LLVM_CLANG_VERSION}.")

		set(CMAKE_AR "${LLVM_AR}" CACHE STRING "" FORCE)
		set(CMAKE_RANLIB "${LLVM_RANLIB}" CACHE STRING "" FORCE)
		set(CMAKE_LINKER "${LLVM_LD}" CACHE STRING "" FORCE)

		set(CMAKE_C_COMPILER "${LLVM_CLANG}" CACHE STRING "" FORCE)
		set(CMAKE_C_COMPILER_AR "${LLVM_AR}" CACHE STRING "" FORCE)
		set(CMAKE_C_COMPILER_RANLIB "${LLVM_RANLIB}" CACHE STRING "" FORCE)
		set(CMAKE_C_COMPILER_LINKER "${LLVM_LD}" CACHE STRING "" FORCE)
		set(CMAKE_C_COMPILER_LINKER_ID "LLD" CACHE STRING "" FORCE)
		set(CMAKE_C_COMPILER_LINKER_VERSION "${LLVM_LD_VERSION}" CACHE STRING "" FORCE)

		set(CMAKE_CXX_COMPILER "${LLVM_CLANGPP}" CACHE STRING "" FORCE)
		set(CMAKE_CXX_COMPILER_AR "${LLVM_AR}" CACHE STRING "" FORCE)
		set(CMAKE_CXX_COMPILER_RANLIB "${LLVM_RANLIB}" CACHE STRING "" FORCE)
		set(CMAKE_CXX_COMPILER_LINKER "${LLVM_LD}" CACHE STRING "" FORCE)
		set(CMAKE_CXX_COMPILER_LINKER_ID "LLD" CACHE STRING "" FORCE)
		set(CMAKE_CXX_COMPILER_LINKER_VERSION "${LLVM_LD_VERSION}" CACHE STRING "" FORCE)

		set(CMAKE_ASM_COMPILER "${LLVM_CLANG}" CACHE STRING "" FORCE)
		set(CMAKE_ASM_COMPILER_AR "${LLVM_AR}" CACHE STRING "" FORCE)
		set(CMAKE_ASM_COMPILER_RANLIB "${LLVM_RANLIB}" CACHE STRING "" FORCE)
		set(CMAKE_ASM_COMPILER_LINKER "${LLVM_LD}" CACHE STRING "" FORCE)
		set(CMAKE_ASM_COMPILER_LINKER_ID "LLD" CACHE STRING "" FORCE)
		set(CMAKE_ASM_COMPILER_LINKER_VERSION "${LLVM_LD_VERSION}" CACHE STRING "" FORCE)

		set(CMAKE_RC_COMPILER "${LLVM_CLANG}" CACHE STRING "" FORCE)
		set(CMAKE_RC_COMPILER_AR "${LLVM_AR}" CACHE STRING "" FORCE)
		set(CMAKE_RC_COMPILER_RANLIB "${LLVM_RANLIB}" CACHE STRING "" FORCE)
		set(CMAKE_RC_COMPILER_LINKER "${LLVM_LD}" CACHE STRING "" FORCE)
		set(CMAKE_RC_COMPILER_LINKER_ID "LLD" CACHE STRING "" FORCE)
		set(CMAKE_RC_COMPILER_LINKER_VERSION "${LLVM_LD_VERSION}" CACHE STRING "" FORCE)

		# Needed otherwise CMake will attempt to use GNU ld, MSVC link.exe, or AppleClangs lld
	#	set(CMAKE_EXE_LINKER_FLAGS_INIT "-fuse-ld=\"${LLVM_LD}\"")
	#	set(CMAKE_STATIC_LINKER_FLAGS_INIT "-fuse-ld=\"${LLVM_LD}\"")
	#	set(CMAKE_MODULE_LINKER_FLAGS_INIT "-fuse-ld=\"${LLVM_LD}\"")
	#	set(CMAKE_SHARED_LINKER_FLAGS_INIT "-fuse-ld=\"${LLVM_LD}\"")

		foreach(_T IN ITEMS CMAKE_AR CMAKE_RANLIB CMAKE_LINKER CMAKE_C_COMPILER CMAKE_C_COMPILER_AR CMAKE_C_COMPILER_RANLIB CMAKE_C_COMPILER_LINKER CMAKE_C_COMPILER_LINKER_ID CMAKE_C_COMPILER_LINKER_VERSION CMAKE_CXX_COMPILER CMAKE_CXX_COMPILER_AR CMAKE_CXX_COMPILER_RANLIB CMAKE_CXX_COMPILER_LINKER CMAKE_CXX_COMPILER_LINKER_ID CMAKE_CXX_COMPILER_LINKER_VERSION CMAKE_ASM_COMPILER CMAKE_ASM_COMPILER_AR CMAKE_ASM_COMPILER_RANLIB CMAKE_ASM_COMPILER_LINKER CMAKE_ASM_COMPILER_LINKER_ID CMAKE_ASM_COMPILER_LINKER_VERSION CMAKE_RC_COMPILER CMAKE_RC_COMPILER_AR CMAKE_RC_COMPILER_RANLIB CMAKE_RC_COMPILER_LINKER CMAKE_RC_COMPILER_LINKER_ID CMAKE_RC_COMPILER_LINKER_VERSION)
			set(ENV{${_T}} "${${_T}}")
		endforeach()
	else()
		message(FATAL_ERROR "Failed to find or provide a compatible LLVM installation.")
	endif()

endif()

list(POP_BACK CMAKE_MESSAGE_INDENT)
