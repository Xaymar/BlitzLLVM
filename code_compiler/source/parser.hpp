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

#pragma once
#include "lexer.hpp"
#include "ast/ast.hpp"
#include "ast/value.hpp"
#include <fstream>
#include <map>
#include <memory>
#include <string>
#include <stack>

namespace BlitzLLVM {
	class Parser {
		public:
		Parser(std::string file);
		~Parser();

		std::unique_ptr<AST::Expression> Parse();

		protected:
		void LogMessage(const char* msg, ...);
		void LogError(const char* msg, ...);

		private:
		std::pair<BlitzLLVM::Lexer::Token, std::string> GetNextToken();

		private:
		std::unique_ptr<AST::Expression> ParseExpression();
		std::unique_ptr<AST::NumberExpression> ParseNumber(BlitzLLVM::Lexer::Token token, std::string value);
		std::unique_ptr<AST::DecimalExpression> ParseDecimal(BlitzLLVM::Lexer::Token token, std::string value);

		private:
		Lexer m_lexer;
		std::stack<std::pair<std::string, std::shared_ptr<std::istream>>> m_files;

	};
}
