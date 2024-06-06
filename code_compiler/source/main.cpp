#include <iostream>
#include "compiler.hpp"

int main(int argc, char** argv) {
	blitz::compiler comp;
	comp.compile(argv[1], std::string(argv[1]) + ".exe");
	std::cin.get();
	return 0;
}
