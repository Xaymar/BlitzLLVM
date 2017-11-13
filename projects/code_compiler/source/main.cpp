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

#include <iostream>
#include "boost/program_options.hpp"
#include "compiler.hpp"
#include "version.h"

#define LICENSE "Copyright (C) 2017 Michael Fabian Dirks\n\
This program comes with ABSOLUTELY NO WARRANTY, for details launch with `--warranty`. This is free software, and you are welcome to redistribute it under certain conditions."

#define WARRANTY "\
THERE IS NO WARRANTY FOR THE PROGRAM, TO THE EXTENT PERMITTED BY APPLICABLE LAW.EXCEPT WHEN OTHERWISE STATED IN \
WRITING THE COPYRIGHT HOLDERS AND / OR OTHER PARTIES PROVIDE THE PROGRAM \"AS IS\" WITHOUT WARRANTY OF ANY KIND, \
EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR \
A PARTICULAR PURPOSE. THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE PROGRAM IS WITH YOU. SHOULD THE PROGRAM \
PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL NECESSARY SERVICING, REPAIR OR CORRECTION."

int main(int argc, char** argv) {
	std::string optInput;
	bool optQuiet, optVerbose;

#pragma region Define Program Options
	boost::program_options::options_description opts_help("Generic");
	opts_help.add_options()
		("help,h", "Show this help message.")
		("warranty", "Show warranty information.")
		("quiet,q", boost::program_options::value<bool>(&optQuiet)->default_value(false), "Use quieter logging.")
		("verbose,v", boost::program_options::value<bool>(&optVerbose)->default_value(false), "Use verbose logging (overrides quiet).")
		;

	boost::program_options::options_description opts_param("Parameters");
	opts_param.add_options()
		("input,i", boost::program_options::value<std::string>(&optInput), "Input .bb file.")
		;

	boost::program_options::options_description opts;
	opts.add(opts_help).add(opts_param);

	boost::program_options::positional_options_description opts_pos;
	opts_pos.add("input", -1);
#pragma endregion Define Program Options

#pragma region Convert ArgC/ArgV to Program Options
	boost::program_options::variables_map vm;
	{
		auto clp = boost::program_options::command_line_parser(argc, argv);
		boost::program_options::store(clp.options(opts).positional(opts_pos).run(), vm);
		boost::program_options::notify(vm);
	}
#pragma endregion Convert ArgC/ArgV to Program Options

#pragma region Header, Warranty, Help
	// Header
	if (!optQuiet || optVerbose) {
		std::cout 
			<< "BlitzLLVM Code Compiler"
			<< " v" << VERSION_MAJOR
			<< "."	<< VERSION_MINOR
			<< "."	<< VERSION_PATCH
			<< " "	<< LICENSE
			<< '\n' << std::endl;
	}

	// Warranty
	if (vm.count("warranty")) {
		std::cout << '\n' << WARRANTY << '\n' << std::endl;
	#ifdef _DEBUG
		std::cin.get();
	#endif
		return 1;
	}

	// Help
	if (vm.empty() || vm.count("help")) {
		std::cout
			<< "Usage: cc [options] <file.bb>" << '\n'
			<< opts
			<< std::endl;
	#ifdef _DEBUG
		std::cin.get();
	#endif
		return 1;
	}
#pragma endregion Header, Warranty, Help

#pragma region Process Input
	BlitzLLVM::Compiler comp;
	comp.Compile(optInput, optInput + ".exe");
#pragma endregion Process Input

#ifdef _DEBUG
	std::cin.get();
#endif
	return 0;
}