#include "compiler.hpp"
#include "parser.hpp"
#include "lexer.hpp"
#include <fstream>
#include <iostream>

blitz::compiler::compiler() {}

blitz::compiler::~compiler() {}

bool blitz::compiler::compile(std::string in, std::string out) {
	/*std::ifstream infile;
	infile.open(in);
	if (infile.bad() || !infile.good() || infile.eof()) {
		std::cerr << "Failed to open file: " << in << std::endl;
		return false;
	}*/

	parser psr = parser(in);
	if (!psr.Parse()) {

	}

	return true;
}
