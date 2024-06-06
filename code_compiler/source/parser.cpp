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

#include "parser.hpp"
#include "ast/function.hpp"
#include <iostream>
#include <vector>
#include <stdarg.h>

BlitzLLVM::Parser::Parser(std::string file) {
	// Try and load the file
	std::shared_ptr<std::ifstream> instream = std::make_shared<std::ifstream>(file);
	if (instream->bad() || !instream->good()) {
		throw std::ios_base::failure("Failed to open file.");
	}
	m_files.push(std::make_pair(file, instream));
}

BlitzLLVM::Parser::~Parser() {
	while (m_files.size() > 0) {
		std::shared_ptr<std::ifstream> file = std::dynamic_pointer_cast<std::ifstream>(m_files.top().second);
		file->close();
		m_files.pop();
	}
}

std::unique_ptr<BlitzLLVM::AST::Expression> BlitzLLVM::Parser::Parse() {
	std::unique_ptr<AST::ScopeExpression> scope = std::make_unique<AST::ScopeExpression>();

	std::unique_ptr<AST::Expression> expr;
	while ((expr = std::move(ParseExpression())) != nullptr) {
		scope->AddExpression(std::move(expr));
	}

	return std::move(scope);
}

void BlitzLLVM::Parser::LogMessage(const char* msg, ...) {
	std::vector<char> buf(65535);
	va_list val;
	va_start(val, msg);
	int rval = vsnprintf(buf.data(), buf.size(), msg, val);
	va_end(val);
	std::cout << buf.data() << '\n';
}

void BlitzLLVM::Parser::LogError(const char* msg, ...) {
	std::vector<char> buf(65535);
	va_list val;
	va_start(val, msg);
	int rval = vsnprintf(buf.data(), buf.size(), msg, val);
	va_end(val);
	std::cerr << buf.data() << '\n';
}

std::pair<BlitzLLVM::Lexer::Token, std::string> BlitzLLVM::Parser::GetNextToken() {
	return m_lexer.GetNextToken(m_files.top().second);
}

std::unique_ptr<BlitzLLVM::AST::Expression> BlitzLLVM::Parser::ParseExpression() {
	while (true) {
		auto tkn = GetNextToken();

		switch (tkn.first) {
			case BlitzLLVM::Lexer::Token::TokenNewLine:
			case BlitzLLVM::Lexer::Token::TokenComment:
				// Skip Comments, since we don't really need them for the AST.
				continue;
			case BlitzLLVM::Lexer::Token::TokenPlus:
			case BlitzLLVM::Lexer::Token::TokenMinus:


			default: // End Of File / Unknown
			case BlitzLLVM::Lexer::Token::TokenUnknown:
			case BlitzLLVM::Lexer::Token::TokenEOF:
				return nullptr;
				break;
		}
	}
}

std::unique_ptr<BlitzLLVM::AST::NumberExpression> BlitzLLVM::Parser::ParseNumber(BlitzLLVM::Lexer::Token token, std::string value) {
	if (token != Lexer::Token::TokenNumber) {
		LogError("Unexpected Token during parsing, expected number.");
		return nullptr;
	}

	char* endptr = const_cast<char*>(value.c_str() + value.size());
	int32_t parsed = strtol(value.c_str(), &endptr, 10);
	if (errno == ERANGE) {
		LogError("Number out of range.");
		return nullptr;
	}

	return std::make_unique<BlitzLLVM::AST::NumberExpression>(parsed);
}

std::unique_ptr<BlitzLLVM::AST::DecimalExpression> BlitzLLVM::Parser::ParseDecimal(BlitzLLVM::Lexer::Token token, std::string value) {
	if (token != Lexer::Token::TokenNumber) {
		LogError("Unexpected Token during parsing, expected number.");
		return nullptr;
	}

	char* endptr = const_cast<char*>(value.c_str() + value.size());
	float_t parsed = strtof(value.c_str(), &endptr);
	if (errno == ERANGE) {
		LogError("Number out of range.");
		return nullptr;
	}

	return std::make_unique<BlitzLLVM::AST::DecimalExpression>(parsed);
}
