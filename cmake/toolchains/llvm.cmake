# TinyAudioLink - Seamlessly transfer Audio between USB capable devices
# Copyright (C) 2019 Michael Fabian 'Xaymar' Dirks
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

find_program(
	CLANG_C_COMPILER
	NAMES
		clang
		clang-cl
		clang++
		clang-cpp
	NO_CACHE
)
find_program(
	CLANG_CPP_COMPILER
	NAMES
		clang++
		clang-cpp
		clang
		clang-cl
	NO_CACHE
)
find_program(
	CLANG_LLVM_AR
	NAMES
		llvm-ar
	NO_CACHE
)
find_program(
	CLANG_LLVM_LD_LDD
	NAMES
		ld.lld
	NO_CACHE
)
mark_as_advanced(CLANG_C_COMPILER CLANG_CPP_COMPILER CLANG_LLVM_AR CLANG_LLVM_LD_LDD)

set(CMAKE_C_COMPILER "${CLANG_C_COMPILER}")
set(CMAKE_CXX_COMPILER "${CLANG_CPP_COMPILER}")
set(CMAKE_AR "${CLANG_LLVM_AR}")

if(CMAKE_VERSION VERSION_GREATER_EQUAL 3.29)
	set(CMAKE_LINKER_TYPE "LLD")
else()
	set(CMAKE_EXE_LINKER_FLAGS_INIT "-fuse-ld=\"${CLANG_LLVM_LD_LDD}\"")
	set(CMAKE_STATIC_LINKER_FLAGS_INIT "-fuse-ld=\"${CLANG_LLVM_LD_LDD}\"")
	set(CMAKE_MODULE_LINKER_FLAGS_INIT "-fuse-ld=\"${CLANG_LLVM_LD_LDD}\"")
	set(CMAKE_SHARED_LINKER_FLAGS_INIT "-fuse-ld=\"${CLANG_LLVM_LD_LDD}\"")
endif()
