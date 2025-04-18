# Copyright 2017-2025 Michael Fabian 'Xaymar' Dirks <info@xaymar.com>
#
# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS “AS IS” AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

cmake_minimum_required(VERSION 4.0 FATAL_ERROR)

################################################################################
# CMake Setup
################################################################################
project(BlitzLLVM)
list(APPEND CMAKE_MESSAGE_INDENT "[${PROJECT_NAME}] ")

# Module Search Paths
list(APPEND CMAKE_MODULE_PATH
	"${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules"
	"${CMAKE_CURRENT_SOURCE_DIR}/cmake"
)

# Include default modules
#- Interprocedural optimizations
include("CheckIPOSupported")

set_property(GLOBAL PROPERTY USE_FOLDERS ON)

################################################################################
# Project
################################################################################

# Metadata
project(
	${PROJECT_NAME}
)
set(PROJECT_IDENTIFER "com.xaymar.blitzllvm")
set(PROJECT_TITLE "BlitzLLVM")
set(PROJECT_AUTHORS "Xaymar <info@xaymar.com>") # ToDo: Generate from AUTHORS
set(PROJECT_COPYRIGHT "All Rights Reserved. See LICENSE file for more information") # ToDo: Generate from LICENSE
set(PROJECT_TRADEMARKS "")

function(init_project TARGET)
	set_target_properties(${TARGET} PROPERTIES
		# Always generate position independent code.
		POSITION_INDEPENDENT_CODE ON

		# Set C++ Standard and Extensions
		C_STANDARD 17
		C_STANDARD_REQUIRED ON
		CXX_STANDARD 20
		CXX_STANDARD_REQUIRED ON
		CXX_EXTENSIONS OFF

		# Remove prefix from generated files.
		PREFIX ""
		IMPORT_PREFIX ""

		# Never treat warnings as errors.
		COMPILE_WARNING_AS_ERROR OFF
	)
	target_compile_definitions(${TARGET} PRIVATE
		__STDC_WANT_LIB_EXT1__=1
	)

	if(WIN32)
		target_compile_definitions(${TARGET} PRIVATE
			# windows.h
			#- Disable MIN/MAX macro as this breaks a lot of code.
			NOMINMAX
			#- Disable IN/OUT macro as this breaks a lot of code.
			NOINOUT
		)
	endif()

	if(MSVC) # Microsoft Visual C/C++
		target_compile_definitions(${TARGET} PRIVATE
			# Disable useless/terrible behavior from MSVC
			_CRT_SECURE_NO_WARNINGS
			_ENABLE_EXTENDED_ALIGNED_STORAGE
		)
		target_compile_options(${TARGET} PRIVATE
			# Dynamically link Microsoft C/C++ Redistributable.
			$<$<CONFIG:>:/MD>
			$<$<CONFIG:Debug>:/MDd>
			$<$<CONFIG:Release>:/MD>
			$<$<CONFIG:RelWithDebInfo>:/MD>
			$<$<CONFIG:MinSizeRel>:/MD>

			# Always compile using multiple processors. Why is this defaulting off anyway?!
			/MP

			# We want full exception support all the time, not conditionally.
			/EHa
		)
	endif()
endfunction()

################################################################################
# Sub-projects
################################################################################
add_subdirectory("code_compiler")
