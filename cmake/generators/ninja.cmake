# Copyright (C) 2024-2025 Michael Fabian 'Xaymar' Dirks
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

# This is a script file that installs the necessary "Ninja" and "Ninja Multi-Config" generators.
# Run with `cmake -P cmake/generators/ninja.cmake` from the source directory.

cmake_minimum_required(VERSION 3.30...4.0)
include_guard(GLOBAL)
list(APPEND CMAKE_MESSAGE_INDENT "[Ninja] ")

# Try and figure out what processor we need to get binaries for.
if(CMAKE_HOST_SYSTEM_NAME MATCHES "[Ww]indows")
	string(TOLOWER "$ENV{PROCESSOR_ARCHITECTURE}" _ARCH)
	set(_OS "windows")
elseif(CMAKE_HOST_SYSTEM_NAME MATCHES "[Dd]arwin")
	set(_ARCH "multiarch")
	set(_OS "macos")
elseif(CMAKE_HOST_SYSTEM_NAME MATCHES "[Oo]pen[Bb][Ss][Dd]")
	set(_OS "openbsd")
	execute_process(
		COMMAND "arch"
		OUTPUT_VARIABLE _ARCH
		OUTPUT_STRIP_TRAILING_WHITESPACE
	)
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
endif()

set(NINJA_VERSION "1.12.1")
set(NINJA_DIR "${CMAKE_SOURCE_DIR}/extra/ninja-${NINJA_VERSION}-${_OS}-${_ARCH}")

# Check if Ninja is present and if it is up to date.
find_program(NINJA_BIN
	NAMES
		ninja
	HINTS
		"${NINJA_DIR}/"
	NO_CACHE NO_DEFAULT_PATH NO_PACKAGE_ROOT_PATH NO_CMAKE_PATH NO_CMAKE_ENVIRONMENT_PATH NO_SYSTEM_ENVIRONMENT_PATH NO_CMAKE_SYSTEM_PATH NO_CMAKE_INSTALL_PREFIX NO_CMAKE_FIND_ROOT_PATH
)
if(IS_EXECUTABLE "${NINJA_BIN}")
	execute_process(
		COMMAND ${NINJA_BIN} --version
		OUTPUT_VARIABLE NINJA_VERSION_INSTALLED
		OUTPUT_STRIP_TRAILING_WHITESPACE
	)
	string(REGEX REPLACE "[\r\n]+" "" NINJA_VERSION_INSTALLED "${NINJA_VERSION_INSTALLED}")
	if((EXISTS NINJA_BIN) AND (NINJA_VERSION_INSTALLED VERSION_LESS NINJA_VERSION))
		message(STATUS "Found outdated v${NINJA_VERSION_INSTALLED}.")
	else()
		message(STATUS "Found v${NINJA_VERSION_INSTALLED}.")
	endif()
endif()

if((NOT IS_EXECUTABLE "${NINJA_BIN}") OR (NINJA_VERSION_INSTALLED VERSION_LESS NINJA_VERSION))
	# It isn't up to date or doesn't exist, so try to download the latest version.

	# First we'll have to figure out what we need to download, and from where.
	if(_OS MATCHES "windows")
		# Windows and Windows-like
		SET (_FILE_EXT "zip")
		if(_ARCH MATCHES "([xX]86)|([aA][mM][dD]64)")
			# It's x86, x86-64 or amd64
			SET (_FILE_NAME "ninja-win")
		else() 
			# Assume ARM or ARM64
			SET (_FILE_NAME "ninja-winarm64")
		endif()
	elseif(_OS MATCHES "macos")
		# MacOS and MacOS-like
		SET (_FILE_EXT "zip")
		SET (_FILE_NAME "ninja-mac")
	else()
		# Assume this to be generic Unix-like.
		SET (_FILE_EXT "tar.xz")
		if(_ARCH MATCHES "([xX]86)|([aA][mM][dD]64)")
			# It's x86, x86-64 or amd64
			SET (_FILE_NAME "ninja-linux")
		else() 
			# Assume ARM or ARM64
			SET (_FILE_NAME "ninja-linux-aarch64")
		endif()
	endif()

	# Download the ideal version.
	message(STATUS "Downloading Ninja v${NINJA_VERSION}...")
	file(DOWNLOAD
		"https://github.com/ninja-build/ninja/releases/download/v${NINJA_VERSION}/${_FILE_NAME}.${_FILE_EXT}"
		"${NINJA_DIR}.${_FILE_EXT}"
	)

	# Extract it.
	message(STATUS "Extracting...")
	file(ARCHIVE_EXTRACT
		INPUT "${NINJA_DIR}.${_FILE_EXT}"
		DESTINATION "${NINJA_DIR}/"
	)

	# Delete the archive itself.
	message(STATUS "Cleaning...")
	file(REMOVE "${NINJA_DIR}.${_FILE_EXT}")

	# Check if Ninja is present and if it is up to date.
	message(STATUS "Testing...")
	find_program(NINJA_BIN
		NAMES
			ninja
		HINTS
			"${NINJA_DIR}/"
		NO_CACHE NO_DEFAULT_PATH NO_PACKAGE_ROOT_PATH NO_CMAKE_PATH NO_CMAKE_ENVIRONMENT_PATH NO_SYSTEM_ENVIRONMENT_PATH NO_CMAKE_SYSTEM_PATH NO_CMAKE_INSTALL_PREFIX NO_CMAKE_FIND_ROOT_PATH
	)
	if(IS_EXECUTABLE "${NINJA_BIN}")
		execute_process(
			COMMAND ${NINJA_BIN} --version
			OUTPUT_VARIABLE NINJA_VERSION_INSTALLED
			OUTPUT_STRIP_TRAILING_WHITESPACE
		)
		string(REGEX REPLACE "[\r\n]+" "" NINJA_VERSION_INSTALLED "${NINJA_VERSION_INSTALLED}")
	endif()
endif()

if((NOT IS_EXECUTABLE "${NINJA_BIN}") OR (NINJA_VERSION_INSTALLED VERSION_LESS NINJA_VERSION))
	message(STATUS "NINJA_DIR=${NINJA_DIR}")
	message(STATUS "NINJA_BIN=${NINJA_BIN}")
	message(STATUS "NINJA_VERSION=${NINJA_VERSION}")
	message(STATUS "NINJA_VERSION_INSTALLED=${NINJA_VERSION_INSTALLED}")
	message(FATAL_ERROR "Failed to install newer version of Ninja.")
endif()

set(CMAKE_MAKE_PROGRAM "${NINJA_BIN}" CACHE STRING "" FORCE)