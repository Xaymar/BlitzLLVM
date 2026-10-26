# Copyright 2026 Narta Xaymar Dirks <info@xaymar.com>
#
# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
#
# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS “AS IS” AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# ExternalContent is an attempt at solving the issues I have with FetchContent and ExternalProject:
# - Both pollute the parent cache with variables and aren't fully separated.
# - Both are considerably slower.
# - Anything that uses them ends up with poor performance too.

# Goals:
# - Never pollute the parent cache unless absolutely needed.

#!TODO: Add support for older CMake versions.
cmake_minimum_required(VERSION 4.2.0)

function(InitializeExternalContent)
endfunction()

macro(ExternalContent_ParseURL OUTPUT_VAR URL)
	# Parse the given url.
	string(REGEX
		MATCH "^(([^:/?#]+):)?(//([^/?#]*))?([^?#]*)(\\?([^#]*))?(#(.*))?"
		URL_MATCH
		"${URL}"
	)
	if(NOT "${URL}" STREQUAL "${URL_MATCH}")
		message(FATAL_ERROR "ExternalContent: Failed to parse URL '${URL}' completely. Only managed to parse '${URL_MATCH}'.")
	endif()

	set(${OUTPUT_VAR}_PROTOCOL_FULL ${CMAKE_MATCH_1})
	set(${OUTPUT_VAR}_PROTOCOL ${CMAKE_MATCH_2})
	set(${OUTPUT_VAR}_HOST_FULL ${CMAKE_MATCH_3})
	set(${OUTPUT_VAR}_HOST ${CMAKE_MATCH_4})
	set(${OUTPUT_VAR}_PATH ${CMAKE_MATCH_5})
	set(${OUTPUT_VAR}_QUERY_FULL ${CMAKE_MATCH_6})
	set(${OUTPUT_VAR}_QUERY ${CMAKE_MATCH_7})
	set(${OUTPUT_VAR}_FRAGMENT_FULL ${CMAKE_MATCH_8})
	set(${OUTPUT_VAR}_FRAGMENT ${CMAKE_MATCH_9})
endmacro()

macro(ExternalContent_ParsePath OUTPUT_VAR INPUT_VAR)
	cmake_path(GET "${INPUT_VAR}" FILENAME "${OUTPUT_VAR}_FILENAME")
	cmake_path(GET "${INPUT_VAR}" EXTENSION "${OUTPUT_VAR}_EXTENSION")
endmacro()

function(ExternalContent)
	set(EXTERNALCONTENT_PREFIX "${CMAKE_BINARY_DIR}/ExternalContentFiles/")

	if(TRUE) # Resolve dependencies
		# Dependency: Git
		find_package(Git QUIET)
	endif()

	if(TRUE) # Parse and validate the arguments
		# Ensure any missing value is at it's default value
		set(EXTERNALCONTENT_NAME "")
		set(EXTERNALCONTENT_TEMP_PATH "")
		set(EXTERNALCONTENT_SOURCE_PATH "")
		set(EXTERNALCONTENT_BINARY_PATH "")
		set(EXTERNALCONTENT_INSTALL_PATH "")
		set(EXTERNALCONTENT_BUILDSYSTEM_SUFFIX "")
		set(EXTERNALCONTENT_SKIP_DOWNLOAD OFF)
		set(EXTERNALCONTENT_DIRTY OFF)
		set(EXTERNALCONTENT_DOWNLOAD_URL "")
		set(EXTERNALCONTENT_DOWNLOAD_FILE "")
		set(EXTERNALCONTENT_DOWNLOAD_HASH "")
		set(EXTERNALCONTENT_GIT_URL OFF)
		set(EXTERNALCONTENT_GIT_REF OFF)
		set(EXTERNALCONTENT_GIT_CLONE_ARGS "")
		set(EXTERNALCONTENT_GIT_CHECKOUT_ARGS "")
		set(EXTERNALCONTENT_SKIP_PATCH OFF)
		set(EXTERNALCONTENT_PATCH_FUNCTION OFF)
		set(EXTERNALCONTENT_DIRTY OFF)
		set(EXTERNALCONTENT_SKIP_CONFIGURE OFF)
		set(EXTERNALCONTENT_CONFIGURE_FUNCTION OFF)
		set(EXTERNALCONTENT_CONFIGURE_ARGS "")
		set(EXTERNALCONTENT_DIRTY OFF)
		set(EXTERNALCONTENT_SKIP_BUILD OFF)
		set(EXTERNALCONTENT_BUILD_FUNCTION OFF)
		set(EXTERNALCONTENT_BUILD_ARGS "")
		set(EXTERNALCONTENT_DIRTY OFF)
		set(EXTERNALCONTENT_SKIP_INSTALL OFF)
		set(EXTERNALCONTENT_INSTALL_FUNCTION OFF)
		set(EXTERNALCONTENT_INSTALL_ARGS "")
		set(EXTERNALCONTENT_DIRTY OFF)

		set(_EXTERNALCONTENT_FLAGS
			## Skip the download step entirely.
			"SKIP_DOWNLOAD"

			## Skip the configure step entirely.
			"SKIP_CONFIGURE"

			## Skip the patch step entirely.
			"SKIP_PATCH"

			## Skip the build step entirely.
			"SKIP_BUILD"

			## Skip the install step entirely.
			"SKIP_INSTALL"
		)
		set(_EXTERNALCONTENT_PARAMS_SINGLE
			## What is this external content called?
			# Should be a unique name that also is a valid filesystem directory name.
			"NAME"

			## Where should we place the temporary files?
			#
			# Optional.
			"TEMP_PATH"

			## Where should we place the source files?
			# You can also specify this in combination with SKIP_DOWNLOAD to use existing files.
			#
			# Optional.
			"SOURCE_PATH"

			## Where should we place the binary files (if any)?
			#
			# Optional. Ignored if SKIP_BUILD is set.
			"BINARY_PATH"

			## Where should we place the installable files (if any)?
			#
			# Optional. Ignored if SKIP_INSTALL is set.
			"INSTALL_PATH"

			## (download) From which url should this be downloaded?
			# Required if no other method is provided.
			"DOWNLOAD_URL"

			## (download) What is the file called?
			# Optional, but required if the URL does not contain a file name.
			"DOWNLOAD_FILE"

			## (download) What is the expected hash of the download?
			# Should be in the format: (type);(hash)
			# See [https://cmake.org/cmake/help/latest/command/string.html#hash] for a list of valid hash types.
			#
			# Optional, but recommended.
			"DOWNLOAD_HASH"

			## (git) Git repository to clone.
			# Required if no other method is provided.
			"GIT_URL"

			## (git) Git reference to clone/checkout.
			# Required.
			"GIT_REF"

			## Where in the downloaded directory is the actual content located?
			# Some projects store their key configuration files outside of the parent tree.
			#
			# Optional.
			"BUILDSYSTEM_SUFFIX"

			## Provide a custom function for the configure step.
			# This function is expected to message(FATAL_ERROR) if an error occurs.
			#
			# Function Signature:
			#   function(my_custom_configure NAME SOURCE_PATH BINARY_PATH INSTALL_PATH)
			#     # ...
			#   endfunction()
			#
			# Optional.
			"CONFIGURE_FUNCTION"

			## Provide a custom function for the patch step.
			# This function is expected to message(FATAL_ERROR) if an error occurs.
			#
			# Function Signature:
			#   function(my_custom_patch NAME SOURCE_PATH BINARY_PATH INSTALL_PATH)
			#     # ...
			#   endfunction()
			#
			# Optional.
			"PATCH_FUNCTION"

			## Provide a custom function for the build step.
			# This function is expected to message(FATAL_ERROR) if an error occurs.
			#
			# Function Signature:
			#   function(my_custom_build NAME SOURCE_PATH BINARY_PATH INSTALL_PATH)
			#     # ...
			#   endfunction()
			#
			# Optional.
			"BUILD_FUNCTION"

			## Provide a custom function for the install step.
			# This function is expected to message(FATAL_ERROR) if an error occurs.
			#
			# Function Signature:
			#   function(my_custom_install NAME SOURCE_PATH BINARY_PATH INSTALL_PATH)
			#     # ...
			#   endfunction()
			#
			# Optional.
			"INSTALL_FUNCTION"
		)
		set(_EXTERNALCONTENT_PARAMS_MULTI
			## (git) Additional options provided to the clone command line.
			# Optional. :)
			"GIT_CLONE_OPTIONS"

			## (git) Additional options provided to the checkout command line.
			# Optional. :)
			"GIT_CHECKOUT_OPTIONS"

			## Provide additional arguments for the configure step.
			# Only used by some build systems.
			#
			# Optional. Ignored if CONFIGURE_FUNCTION is set.
			"CONFIGURE_ARGS"

			## Provide additional arguments for the build step.
			# Only used by some build systems.
			#
			# Optional. Ignored if BUILD_FUNCTION is set.
			"BUILD_ARGS"

			## Provide additional arguments for the install step.
			# Only used by some build systems.
			#
			# Optional. Ignored if INSTALL_FUNCTION is set.
			"INSTALL_ARGS"
		)

		cmake_parse_arguments(PARSE_ARGV 0
			"EXTERNALCONTENT"
			"${_EXTERNALCONTENT_FLAGS}"
			"${_EXTERNALCONTENT_PARAMS_SINGLE}"
			"${_EXTERNALCONTENT_PARAMS_MULTI}"
		)

		# Validate the NAME parameter
		string(LENGTH "${EXTERNALCONTENT_NAME}" EXTERNALCONTENT_NAME_LENGTH)
		if((NOT EXTERNALCONTENT_NAME) OR (EXTERNALCONTENT_NAME_LENGTH EQUAL 0))
			message(STATUS "${EXTERNALCONTENT_NAME} ${EXTERNALCONTENT_NAME_LENGTH}")
			message(FATAL_ERROR "[EC: ${EXTERNALCONTENT_NAME}] You must provide a NAME for the external content.")
		endif()

		# Ensure that we have some kind of source for the content.
		string(LENGTH EXTERNALCONTENT_SOURCE_PATH EXTERNALCONTENT_SOURCE_PATH_LENGTH)
		string(LENGTH EXTERNALCONTENT_DOWNLOAD_URL EXTERNALCONTENT_DOWNLOAD_URL_LENGTH)
		string(LENGTH EXTERNALCONTENT_GIT_URL EXTERNALCONTENT_GIT_URL_LENGTH)
		if(
			(
				SKIP_DOWNLOAD AND (
					(NOT EXTERNALCONTENT_SOURCE_PATH)
					OR (EXTERNALCONTENT_SOURCE_PATH_LENGTH EQUAL 0)
				)
			) OR (
				(
					(NOT EXTERNALCONTENT_DOWNLOAD_URL)
				OR (EXTERNALCONTENT_DOWNLOAD_URL_LENGTH EQUAL 0)
				) AND (
					(NOT EXTERNALCONTENT_GIT_URL)
				OR (EXTERNALCONTENT_GIT_URL_LENGTH EQUAL 0)
				)
			)
		)
			message(FATAL_ERROR "[EC: ${EXTERNALCONTENT_NAME}] You must provide a source for the external content.")
		endif()

		# Ensure that there's always a path for things.
		string(LENGTH "${EXTERNALCONTENT_TEMP_PATH}" EXTERNALCONTENT_TEMP_PATH_LENGTH)
		if((NOT EXTERNALCONTENT_TEMP_PATH) OR (EXTERNALCONTENT_TEMP_PATH_LENGTH EQUAL 0))
			set(EXTERNALCONTENT_TEMP_PATH "${EXTERNALCONTENT_PREFIX}/${EXTERNALCONTENT_NAME}.tmp")
		endif()
		string(LENGTH "${EXTERNALCONTENT_SOURCE_PATH}" EXTERNALCONTENT_SOURCE_PATH_LENGTH)
		if((NOT EXTERNALCONTENT_SOURCE_PATH) OR (EXTERNALCONTENT_SOURCE_PATH_LENGTH EQUAL 0))
			set(EXTERNALCONTENT_SOURCE_PATH "${EXTERNALCONTENT_PREFIX}/${EXTERNALCONTENT_NAME}.src")
		endif()
		string(LENGTH "${EXTERNALCONTENT_BINARY_PATH}" EXTERNALCONTENT_BINARY_PATH_LENGTH)
		if((NOT EXTERNALCONTENT_BINARY_PATH) OR (EXTERNALCONTENT_BINARY_PATH_LENGTH EQUAL 0))
			set(EXTERNALCONTENT_BINARY_PATH "${EXTERNALCONTENT_PREFIX}/${EXTERNALCONTENT_NAME}.bin")
		endif()
		string(LENGTH "${EXTERNALCONTENT_INSTALL_PATH}" EXTERNALCONTENT_INSTALL_PATH_LENGTH)
		if((NOT EXTERNALCONTENT_INSTALL_PATH) OR (EXTERNALCONTENT_INSTALL_PATH_LENGTH EQUAL 0))
			set(EXTERNALCONTENT_INSTALL_PATH "${EXTERNALCONTENT_PREFIX}/${EXTERNALCONTENT_NAME}.dst")
		endif()

		# Validate the download URL
		if(EXTERNALCONTENT_DOWNLOAD_URL)
			ExternalContent_ParseURL(EXTERNALCONTENT_DOWNLOAD_URL "${EXTERNALCONTENT_DOWNLOAD_URL}")
			ExternalContent_ParsePath(EXTERNALCONTENT_DOWNLOAD "EXTERNALCONTENT_DOWNLOAD_URL_PATH")
			if(EXTERNALCONTENT_DOWNLOAD_FILE)
				ExternalContent_ParsePath(EXTERNALCONTENT_DOWNLOAD "EXTERNALCONTENT_DOWNLOAD_FILE")
			else()
				ExternalContent_ParsePath(EXTERNALCONTENT_DOWNLOAD "EXTERNALCONTENT_DOWNLOAD_URL_PATH")
			endif()

			# Set the object that is being used.
			set(EXTERNALCONTENT_DOWNLOAD_OBJECT "${EXTERNALCONTENT_TEMP_PATH}/${EXTERNALCONTENT_DOWNLOAD_FILENAME}")
		endif()

		# Validate the download hash.
		list(LENGTH EXTERNALCONTENT_DOWNLOAD_HASH EXTERNALCONTENT_DOWNLOAD_HASH_LENGTH)
		if(EXTERNALCONTENT_DOWNLOAD_HASH AND (EXTERNALCONTENT_DOWNLOAD_HASH_LENGTH GREATER 0))
			list(GET EXTERNALCONTENT_DOWNLOAD_HASH 0 EXTERNALCONTENT_DOWNLOAD_HASH_TYPE)
			list(GET EXTERNALCONTENT_DOWNLOAD_HASH 1 EXTERNALCONTENT_DOWNLOAD_HASH_HASH)
			string(TOLOWER "${EXTERNALCONTENT_DOWNLOAD_HASH_HASH}" EXTERNALCONTENT_DOWNLOAD_HASH_HASH)
		elseif(EXTERNALCONTENT_DOWNLOAD_HASH)
			message(WARNING "[EC: ${EXTERNALCONTENT_NAME}] DOWNLOAD_HASH set to invalid value '${EXTERNALCONTENT_DOWNLOAD_HASH}', ignoring.")
			unset(EXTERNALCONTENT_DOWNLOAD_HASH)
		endif()

		# Validate the git URL
		if(EXTERNALCONTENT_GIT_URL)
			ExternalContent_ParseURL(EXTERNALCONTENT_GIT_URL "${EXTERNALCONTENT_GIT_URL}")

			string(LENGTH EXTERNALCONTENT_GIT_REF EXTERNALCONTENT_GIT_REF_LENGTH)
			if(((NOT EXTERNALCONTENT_GIT_REF) OR (EXTERNALCONTENT_GIT_REF_LENGTH EQUAL 0)))
				message(FATAL_ERROR "[EC: ${EXTERNALCONTENT_NAME}] GIT_REF must be set when using git for sanity reasons.")
			endif()
		endif()
	endif()

	set(${EXTERNALCONTENT_NAME}_TEMP_PATH "${EXTERNALCONTENT_TEMP_PATH}" PARENT_SCOPE)
	set(${EXTERNALCONTENT_NAME}_SOURCE_PATH "${EXTERNALCONTENT_SOURCE_PATH}" PARENT_SCOPE)
	set(${EXTERNALCONTENT_NAME}_BINARY_PATH "${EXTERNALCONTENT_BINARY_PATH}" PARENT_SCOPE)
	set(${EXTERNALCONTENT_NAME}_INSTALL_PATH "${EXTERNALCONTENT_INSTALL_PATH}" PARENT_SCOPE)

	# Download and extract the content.
	set(EXTERNALCONTENT_DIRTY OFF)
	if(NOT EXTERNALCONTENT_SKIP_DOWNLOAD)
		if(EXTERNALCONTENT_DOWNLOAD_URL) # download: Download the file and optionally verify the hash.
			set(EXTERNALCONTENT_FORCE_DOWNLOAD OFF)

			# Check if the file actually differs (or is missing)
			if(EXISTS "${EXTERNALCONTENT_DOWNLOAD_OBJECT}")
				if(EXTERNALCONTENT_DOWNLOAD_HASH)
					file(${EXTERNALCONTENT_DOWNLOAD_HASH_TYPE} ${EXTERNALCONTENT_DOWNLOAD_OBJECT} EXTERNALCONTENT_DOWNLOAD_OBJECT_HASH)
					if(NOT (EXTERNALCONTENT_DOWNLOAD_OBJECT_HASH STREQUAL EXTERNALCONTENT_DOWNLOAD_HASH_HASH)) # File hash differs.
						set(EXTERNALCONTENT_FORCE_DOWNLOAD ON)
						set(EXTERNALCONTENT_DIRTY ON)
					endif()
				endif()
			else() # File is missing entirely.
				set(EXTERNALCONTENT_DIRTY ON)
			endif()

			# Also consider things dirty if the source directory is missing.
			if(NOT EXISTS ${EXTERNALCONTENT_SOURCE_PATH})
				set(EXTERNALCONTENT_DIRTY ON)
			endif()

			if(EXTERNALCONTENT_DIRTY)
				message(STATUS "[EC: ${EXTERNALCONTENT_NAME}] Downloading '${EXTERNALCONTENT_DOWNLOAD_FILE}' from '${EXTERNALCONTENT_DOWNLOAD_URL}'...")

				if((NOT EXISTS "${EXTERNALCONTENT_DOWNLOAD_OBJECT}") OR EXTERNALCONTENT_FORCE_DOWNLOAD)
					# Download the new file.
					file(DOWNLOAD "${EXTERNALCONTENT_DOWNLOAD_URL}" "${EXTERNALCONTENT_DOWNLOAD_OBJECT}" SHOW_PROGRESS)

					# Verify the hash matches.
					if(EXTERNALCONTENT_DOWNLOAD_HASH)
						file(${EXTERNALCONTENT_DOWNLOAD_HASH_TYPE} ${EXTERNALCONTENT_DOWNLOAD_OBJECT} EXTERNALCONTENT_DOWNLOAD_OBJECT_HASH)
						if(NOT (EXTERNALCONTENT_DOWNLOAD_OBJECT_HASH STREQUAL EXTERNALCONTENT_DOWNLOAD_HASH_HASH)) # File hash differs.
							file(REMOVE "${EXTERNALCONTENT_DOWNLOAD_OBJECT}")
							message(FATAL_ERROR "[EC: ${EXTERNALCONTENT_NAME}] Downloaded file has hash '${EXTERNALCONTENT_DOWNLOAD_OBJECT_HASH}' but expected hash '${EXTERNALCONTENT_DOWNLOAD_HASH_HASH}'. Aborting.")
						endif()
					endif()
				endif()

				# Remove the previously extracted content.
				if(EXISTS ${EXTERNALCONTENT_SOURCE_PATH})
					file(REMOVE_RECURSE "${EXTERNALCONTENT_SOURCE_PATH}")
				endif()

				# Extract the whole thing.
				file(ARCHIVE_EXTRACT
					INPUT "${EXTERNALCONTENT_DOWNLOAD_OBJECT}"
					DESTINATION "${EXTERNALCONTENT_SOURCE_PATH}"
					VERBOSE
				)
			else()
				message(STATUS "[EC: ${EXTERNALCONTENT_NAME}] Skipping download as nothing has changed.")
			endif()
		elseif(EXTERNALCONTENT_GIT_URL) # git: Clone or Checkout to the specific repository.
			set(EXTERNALCONTENT_GIT_CLONE_ARGS
				clone
				${EXTERNALCONTENT_GIT_CLONE_OPTIONS}
				-v
				-b ${EXTERNALCONTENT_GIT_REF}
				"${EXTERNALCONTENT_GIT_URL}"
				"${EXTERNALCONTENT_SOURCE_PATH}"
			)
			set(EXTERNALCONTENT_GIT_CHECKOUT_ARGS
				checkout
				${EXTERNALCONTENT_GIT_CHECKOUT_OPTIONS}
				-f
				${EXTERNALCONTENT_GIT_REF}
			)

			# Hash the given options.
			string(SHA3_512 EXTERNALCONTENT_GIT_CLONE_ARGS_HASH "${EXTERNALCONTENT_SOURCE_PATH} ${EXTERNALCONTENT_GIT_CLONE_ARGS}")
			string(SHA3_512 EXTERNALCONTENT_GIT_CHECKOUT_ARGS_HASH "${EXTERNALCONTENT_SOURCE_PATH} ${EXTERNALCONTENT_GIT_CHECKOUT_ARGS}")

			# Ensure that the commands still match up.
			if(EXISTS "${EXTERNALCONTENT_TEMP_PATH}/git-clone.sha3")
				file(READ "${EXTERNALCONTENT_TEMP_PATH}/git-clone.sha3" EXTERNALCONTENT_HASH_CMP)
				if(NOT (EXTERNALCONTENT_HASH_CMP STREQUAL EXTERNALCONTENT_GIT_CLONE_ARGS_HASH))
					message(STATUS "[EC: ${EXTERNALCONTENT_NAME}] Clone command changed, cloning again...")
					set(EXTERNALCONTENT_FORCE_CLONE ON)
					set(EXTERNALCONTENT_DIRTY ON)
				endif()
			else()
				set(EXTERNALCONTENT_FORCE_CLONE ON)
				set(EXTERNALCONTENT_DIRTY ON)
			endif()
			if(EXISTS "${EXTERNALCONTENT_TEMP_PATH}/git-checkout.sha3")
				file(READ "${EXTERNALCONTENT_TEMP_PATH}/git-checkout.sha3" EXTERNALCONTENT_HASH_CMP)
				if(NOT (EXTERNALCONTENT_HASH_CMP STREQUAL EXTERNALCONTENT_GIT_CHECKOUT_ARGS_HASH))
					set(EXTERNALCONTENT_DIRTY ON)
				endif()
			else()
				set(EXTERNALCONTENT_DIRTY ON)
			endif()

			# Delete the directory if the clone args are dirty or if the directory isn't a git repository
			if((EXISTS "${EXTERNALCONTENT_SOURCE_PATH}") AND (EXTERNALCONTENT_FORCE_CLONE OR (NOT EXISTS "${EXTERNALCONTENT_SOURCE_PATH}/.git")))
				file(REMOVE_RECURSE "${EXTERNALCONTENT_SOURCE_PATH}")
				set(EXTERNALCONTENT_DIRTY ON)
			endif()
			if(NOT EXISTS "${EXTERNALCONTENT_SOURCE_PATH}")
				# If the directory doesn't exist, we'll treat it as dirty and create it.
				set(EXTERNALCONTENT_DIRTY ON)
				file(MAKE_DIRECTORY "${EXTERNALCONTENT_SOURCE_PATH}")
			endif()

			#!TODO: Reduce complex git commands?

			if(EXTERNALCONTENT_DIRTY)
				# Do we need to clone or checkout?
				if(NOT EXISTS "${EXTERNALCONTENT_SOURCE_PATH}/.git")
					message(STATUS "[EC: ${EXTERNALCONTENT_NAME}] Cloning via git...")
					execute_process(
						COMMAND "${GIT_EXECUTABLE}" ${EXTERNALCONTENT_GIT_CLONE_ARGS}
						WORKING_DIRECTORY "${EXTERNALCONTENT_SOURCE_PATH}"
						COMMAND_ECHO STDOUT
					)
				else()
					message(STATUS "[EC: ${EXTERNALCONTENT_NAME}] Checking out via git...")
					execute_process(
						COMMAND "${GIT_EXECUTABLE}" ${EXTERNALCONTENT_GIT_CHECKOUT_ARGS}
						WORKING_DIRECTORY "${EXTERNALCONTENT_SOURCE_PATH}"
						COMMAND_ECHO STDOUT
					)
				endif()

				# Write the hash to the cache file.
				file(WRITE "${EXTERNALCONTENT_TEMP_PATH}/git-clone.sha3" "${EXTERNALCONTENT_GIT_CLONE_ARGS_HASH}")
				file(WRITE "${EXTERNALCONTENT_TEMP_PATH}/git-checkout.sha3" "${EXTERNALCONTENT_GIT_CHECKOUT_ARGS_HASH}")
			else()
				message(STATUS "[EC: ${EXTERNALCONTENT_NAME}] Skipping download as nothing has changed.")
			endif()
		else()
			message(FATAL_ERROR "[EC: ${EXTERNALCONTENT_NAME}] Unknown download type but SKIP_DOWNLOAD is not set.")
		endif()
	endif()

	# Patch
	if(NOT EXTERNALCONTENT_SKIP_PATCH)
		if(EXTERNALCONTENT_PATCH_FUNCTION)
			cmake_language(EVAL CODE "${EXTERNALCONTENT_PATCH_FUNCTION}(\"${EC_TEMP_PATH}\" \"${EXTERNALCONTENT_SOURCE_PATH}\" \"${EXTERNALCONTENT_BINARY_PATH}\" \"${EXTERNALCONTENT_INSTALL_PATH}\")")
		endif()
	endif()

	# Configure
	if(NOT EXTERNALCONTENT_SKIP_CONFIGURE)
		if(EXTERNALCONTENT_CONFIGURE_FUNCTION)
			cmake_language(EVAL CODE "${EXTERNALCONTENT_CONFIGURE_FUNCTION}(\"${EC_TEMP_PATH}\" \"${EXTERNALCONTENT_SOURCE_PATH}\" \"${EXTERNALCONTENT_BINARY_PATH}\" \"${EXTERNALCONTENT_INSTALL_PATH}\")")
		elseif(EXISTS "${EXTERNALCONTENT_SOURCE_PATH}/${EXTERNALCONTENT_BUILDSYSTEM_SUFFIX}CMakeLists.txt")
			# This is a CMake project.

			set(EXTERNALCONTENT_CONFIGURE_ARGS
				-S "${EXTERNALCONTENT_SOURCE_PATH}/${EXTERNALCONTENT_BUILDSYSTEM_SUFFIX}"
				-B "${EXTERNALCONTENT_BINARY_PATH}"
				-Wno-dev
				--no-warn-unused-cli
				--install-prefix "${EXTERNALCONTENT_INSTALL_PATH}"
				${EXTERNALCONTENT_CONFIGURE_ARGS}
			)

			# Hash the given options.
			string(SHA3_512 EXTERNALCONTENT_CONFIGURE_ARGS_HASH "${EC_TEMP_PATH} ${EXTERNALCONTENT_CONFIGURE_ARGS}")

			# Ensure we don't spawn useless sub-processes all the time.
			if(EXISTS "${EXTERNALCONTENT_BINARY_PATH}/CMakeCache.txt")
				if(EXISTS "${EXTERNALCONTENT_TEMP_PATH}/configure.sha3")
					file(READ "${EXTERNALCONTENT_TEMP_PATH}/configure.sha3" EXTERNALCONTENT_HASH_CMP)
					if(NOT (EXTERNALCONTENT_HASH_CMP STREQUAL EXTERNALCONTENT_CONFIGURE_ARGS_HASH))
						set(EXTERNALCONTENT_DIRTY ON)
					endif()
				else()
					set(EXTERNALCONTENT_DIRTY ON)
				endif()
			else()
				set(EXTERNALCONTENT_DIRTY ON)
			endif()

			# Configure & Generate
			if(EXTERNALCONTENT_DIRTY)
				execute_process(
					COMMAND "cmake" ${EXTERNALCONTENT_CONFIGURE_ARGS}
					WORKING_DIRECTORY "${EXTERNALCONTENT_SOURCE_PATH}/${EXTERNALCONTENT_BUILDSYSTEM_SUFFIX}"
					COMMAND_ECHO STDOUT
				)

				# Write the hash to the cache file.
				file(WRITE "${EXTERNALCONTENT_TEMP_PATH}/configure.sha3" "${EXTERNALCONTENT_CONFIGURE_ARGS_HASH}")
			else()
				message(STATUS "[EC: ${EXTERNALCONTENT_NAME}] Skipping configure as nothing has changed.")
			endif()
		elseif(EXISTS "${EXTERNALCONTENT_SOURCE_PATH}/${EXTERNALCONTENT_BUILDSYSTEM_SUFFIX}meson.build")
			# This is a meson project.

			set(EXTERNALCONTENT_CONFIGURE_ARGS
				setup build
				--prefix "${EXTERNALCONTENT_INSTALL_PATH}"
				${EXTERNALCONTENT_CONFIGURE_ARGS}
			)

			# Hash the given options.
			string(SHA3_512 EXTERNALCONTENT_CONFIGURE_ARGS_HASH "${EC_TEMP_PATH} ${EXTERNALCONTENT_CONFIGURE_ARGS}")

			# Test if there were any changes only if we're not already in a dirty state.
			if(NOT EXTERNALCONTENT_DIRTY)
				# Ensure we don't spawn useless sub-processes all the time.
				if(EXISTS "${EXTERNALCONTENT_BINARY_PATH}/CMakeCache.txt")
					if(EXISTS "${EXTERNALCONTENT_TEMP_PATH}/configure.sha3")
						file(READ "${EXTERNALCONTENT_TEMP_PATH}/configure.sha3" EXTERNALCONTENT_HASH_CMP)
						if(NOT (EXTERNALCONTENT_HASH_CMP STREQUAL EXTERNALCONTENT_CONFIGURE_ARGS_HASH))
							set(EXTERNALCONTENT_DIRTY ON)
						endif()
					else()
						set(EXTERNALCONTENT_DIRTY ON)
					endif()
				else()
					set(EXTERNALCONTENT_DIRTY ON)
				endif()
			endif()

			# Configure & Generate
			if(EXTERNALCONTENT_DIRTY)
				execute_process(
					COMMAND "meson" ${EXTERNALCONTENT_CONFIGURE_ARGS}
					WORKING_DIRECTORY "${EXTERNALCONTENT_SOURCE_PATH}/${EXTERNALCONTENT_BUILDSYSTEM_SUFFIX}"
					COMMAND_ECHO STDOUT
				)

				# Write the hash to the cache file.
				file(WRITE "${EXTERNALCONTENT_TEMP_PATH}/configure.sha3" "${EXTERNALCONTENT_CONFIGURE_ARGS_HASH}")
			else()
				message(STATUS "[EC: ${EXTERNALCONTENT_NAME}] Skipping configure as nothing has changed.")
			endif()
		else()
			message(FATAL_ERROR "[EC: ${EXTERNALCONTENT_NAME}] We don't know how to handle this build system yet. Consider using CONFIGURE_FUNCTION or SKIP_CONFIGURE.")
		endif()
	endif()

	# Build
	if(NOT EXTERNALCONTENT_SKIP_BUILD)
		if(EXTERNALCONTENT_BUILD_FUNCTION)
			cmake_language(EVAL CODE "${EXTERNALCONTENT_BUILD_FUNCTION}(\"${EC_TEMP_PATH}\" \"${EXTERNALCONTENT_SOURCE_PATH}\" \"${EXTERNALCONTENT_BINARY_PATH}\" \"${EXTERNALCONTENT_INSTALL_PATH}\")")
		elseif(EXISTS "${EXTERNALCONTENT_SOURCE_PATH}/CMakeLists.txt")
			# This is a CMake project.

			set(EXTERNALCONTENT_BUILD_ARGS
				"--build" "${EXTERNALCONTENT_BINARY_PATH}"
				${EXTERNALCONTENT_BUILD_ARGS}
			)

			# Hash the given options.
			string(SHA3_512 EXTERNALCONTENT_BUILD_ARGS_HASH "${EC_TEMP_PATH} ${EXTERNALCONTENT_SOURCE_PATH} ${EXTERNALCONTENT_BINARY_PATH} ${EXTERNALCONTENT_INSTALL_PATH} ${EXTERNALCONTENT_BUILD_ARGS}")

			# Test if there were any changes only if we're not already in a dirty state.
			if(NOT EXTERNALCONTENT_DIRTY)
				# Ensure we don't spawn useless sub-processes all the time.
				if(EXISTS "${EXTERNALCONTENT_TEMP_PATH}/build.sha3")
					file(READ "${EXTERNALCONTENT_TEMP_PATH}/build.sha3" EXTERNALCONTENT_HASH_CMP)
					if(NOT (EXTERNALCONTENT_HASH_CMP STREQUAL EXTERNALCONTENT_BUILD_ARGS_HASH))
						set(EXTERNALCONTENT_DIRTY ON)
					endif()
				else()
					set(EXTERNALCONTENT_DIRTY ON)
				endif()
			endif()

			# Build
			if(EXTERNALCONTENT_DIRTY)
				execute_process(
					COMMAND "cmake" ${EXTERNALCONTENT_BUILD_ARGS}
					WORKING_DIRECTORY "${EXTERNALCONTENT_BINARY_PATH}"
					COMMAND_ECHO STDOUT
				)

				# Write the hash to the cache file.
				file(WRITE "${EXTERNALCONTENT_TEMP_PATH}/build.sha3" "${EXTERNALCONTENT_BUILD_ARGS_HASH}")
			else()
				message(STATUS "[EC: ${EXTERNALCONTENT_NAME}] Skipping build as nothing has changed.")
			endif()
		elseif(EXISTS "${EXTERNALCONTENT_SOURCE_PATH}/${EXTERNALCONTENT_BUILDSYSTEM_SUFFIX}meson.build")
			# This is a meson project.

			set(EXTERNALCONTENT_BUILD_ARGS
				"--build" "${EXTERNALCONTENT_BINARY_PATH}"
				${EXTERNALCONTENT_BUILD_ARGS}
			)

			# Hash the given options.
			string(SHA3_512 EXTERNALCONTENT_BUILD_ARGS_HASH "${EC_TEMP_PATH} ${EXTERNALCONTENT_SOURCE_PATH} ${EXTERNALCONTENT_BINARY_PATH} ${EXTERNALCONTENT_INSTALL_PATH} ${EXTERNALCONTENT_BUILD_ARGS}")

			# Test if there were any changes only if we're not already in a dirty state.
			if(NOT EXTERNALCONTENT_DIRTY)
				# Ensure we don't spawn useless sub-processes all the time.
				if(EXISTS "${EXTERNALCONTENT_TEMP_PATH}/build.sha3")
					file(READ "${EXTERNALCONTENT_TEMP_PATH}/build.sha3" EXTERNALCONTENT_HASH_CMP)
					if(NOT (EXTERNALCONTENT_HASH_CMP STREQUAL EXTERNALCONTENT_BUILD_ARGS_HASH))
						set(EXTERNALCONTENT_DIRTY ON)
					endif()
				else()
					set(EXTERNALCONTENT_DIRTY ON)
				endif()
			endif()

			# Build
			if(EXTERNALCONTENT_DIRTY)
				execute_process(
					COMMAND "meson" ${EXTERNALCONTENT_BUILD_ARGS}
					WORKING_DIRECTORY "${EXTERNALCONTENT_BINARY_PATH}"
					COMMAND_ECHO STDOUT
				)

				# Write the hash to the cache file.
				file(WRITE "${EXTERNALCONTENT_TEMP_PATH}/build.sha3" "${EXTERNALCONTENT_BUILD_ARGS_HASH}")
			else()
				message(STATUS "[EC: ${EXTERNALCONTENT_NAME}] Skipping build as nothing has changed.")
			endif()
		else()
			message(FATAL_ERROR "[EC: ${EXTERNALCONTENT_NAME}] We don't know how to handle this build system yet. Consider using BUILD_FUNCTION or SKIP_BUILD.")
		endif()
	endif()

	# Install
	if(NOT EXTERNALCONTENT_SKIP_INSTALL)
		if(EXTERNALCONTENT_INSTALL_FUNCTION)
			cmake_language(EVAL CODE "${EXTERNALCONTENT_INSTALL_FUNCTION}(\"${EC_TEMP_PATH}\" \"${EXTERNALCONTENT_SOURCE_PATH}\" \"${EXTERNALCONTENT_BINARY_PATH}\" \"${EXTERNALCONTENT_INSTALL_PATH}\")")
		elseif(EXISTS "${EXTERNALCONTENT_SOURCE_PATH}/CMakeLists.txt")
			# This is a CMake project.

			set(EXTERNALCONTENT_CMAKE_ARGS
				--install "${EXTERNALCONTENT_BINARY_PATH}"
				--prefix "${EXTERNALCONTENT_INSTALL_PATH}"
				${EXTERNALCONTENT_INSTALL_ARGS}
			)

			# Hash the given options.
			string(SHA3_512 EXTERNALCONTENT_INSTALL_ARGS_HASH "${EC_TEMP_PATH} ${EXTERNALCONTENT_SOURCE_PATH} ${EXTERNALCONTENT_BINARY_PATH} ${EXTERNALCONTENT_INSTALL_PATH} ${EXTERNALCONTENT_CMAKE_ARGS}")

			# Test if there were any changes only if we're not already in a dirty state.
			if(NOT EXTERNALCONTENT_DIRTY)
				# Ensure we don't spawn useless sub-processes all the time.
				if(EXISTS "${EXTERNALCONTENT_TEMP_PATH}/install.sha3")
					file(READ "${EXTERNALCONTENT_TEMP_PATH}/install.sha3" EXTERNALCONTENT_HASH_CMP)
					if(NOT (EXTERNALCONTENT_HASH_CMP STREQUAL EXTERNALCONTENT_INSTALL_ARGS_HASH))
						set(EXTERNALCONTENT_DIRTY ON)
					endif()
				else()
					set(EXTERNALCONTENT_DIRTY ON)
				endif()

				# Ensure that we actually have the files installed too.
				if(NOT EXISTS "${EXTERNALCONTENT_INSTALL_PATH}")
					set(EXTERNALCONTENT_DIRTY ON)
				endif()
			endif()

			# Install
			if(EXTERNALCONTENT_DIRTY)
				execute_process(
					COMMAND "cmake" ${EXTERNALCONTENT_CMAKE_ARGS}
					WORKING_DIRECTORY "${EXTERNALCONTENT_BINARY_PATH}"
					COMMAND_ECHO STDOUT
				)

				# Write the hash to the cache file.
				file(WRITE "${EXTERNALCONTENT_TEMP_PATH}/install.sha3" "${EXTERNALCONTENT_INSTALL_ARGS_HASH}")
			else()
				message(STATUS "[EC: ${EXTERNALCONTENT_NAME}] Skipping install as nothing has changed.")
			endif()
		else()
			message(FATAL_ERROR "[EC: ${EXTERNALCONTENT_NAME}] We don't know how to handle this install system yet. Consider using INSTALL_FUNCTION or SKIP_INSTALL.")
		endif()
	endif()
endfunction()
