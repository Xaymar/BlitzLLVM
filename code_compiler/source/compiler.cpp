//	Code Compiler for BlitzLLVM
//	Copyright(C) 2017 Michael Fabian Dirks
//
//	This program is free software : you can redistribute it and/or modify
//	it under the terms of the GNU General Public License as published by
//	the Free Software Foundation, either version 3 of the License, or
//	(at your option) any later version.
//
//	This program is distributed in the hope that it will be useful,
//	but WITHOUT ANY WARRANTY; without even the implied warranty of
//	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.See the
//	GNU General Public License for more details.
//
//	You should have received a copy of the GNU General Public License
//	along with this program.If not, see <https://www.gnu.org/licenses/>.

#include "compiler.hpp"
#include "parser.hpp"
#include "lexer.hpp"
#include <fstream>
#include <iostream>

BlitzLLVM::Compiler::Compiler() {}

BlitzLLVM::Compiler::~Compiler() {}

bool BlitzLLVM::Compiler::Compile(std::string in, std::string out) {
	/*std::ifstream infile;
	infile.open(in);
	if (infile.bad() || !infile.good() || infile.eof()) {
		std::cerr << "Failed to open file: " << in << std::endl;
		return false;
	}*/

	Parser psr = Parser(in);
	if (!psr.Parse()) {

	}

	return true;
}
