#include "parser.hpp"
#include "ast/function.hpp"
#include <iostream>
#include <vector>
#include <stdarg.h>

blitz::parser::parser(std::string file) {
	// Try and load the file
	std::shared_ptr<std::ifstream> instream = std::make_shared<std::ifstream>(file);
	if (instream->bad() || !instream->good()) {
		throw std::ios_base::failure("Failed to open file.");
	}
	m_files.push(std::make_pair(file, instream));
}

blitz::parser::~parser() {
	while (m_files.size() > 0) {
		std::shared_ptr<std::ifstream> file = std::dynamic_pointer_cast<std::ifstream>(m_files.top().second);
		file->close();
		m_files.pop();
	}
}

std::unique_ptr<blitz::AST::Expression> blitz::parser::Parse() {
	std::unique_ptr<AST::ScopeExpression> scope = std::make_unique<AST::ScopeExpression>();

	std::unique_ptr<AST::Expression> expr;
	while ((expr = std::move(parse_expression())) != nullptr) {
		scope->AddExpression(std::move(expr));
	}

	return std::move(scope);
}

void blitz::parser::LogMessage(const char* msg, ...) {
	std::vector<char> buf(65535);
	va_list val;
	va_start(val, msg);
	int rval = vsnprintf(buf.data(), buf.size(), msg, val);
	va_end(val);
	std::cout << buf.data() << '\n';
}

void blitz::parser::LogError(const char* msg, ...) {
	std::vector<char> buf(65535);
	va_list val;
	va_start(val, msg);
	int rval = vsnprintf(buf.data(), buf.size(), msg, val);
	va_end(val);
	std::cerr << buf.data() << '\n';
}

std::pair<blitz::Lexer::Token, std::string> blitz::parser::GetNextToken() {
	return m_lexer.GetNextToken(m_files.top().second);
}

std::unique_ptr<blitz::AST::Expression> blitz::parser::parse_expression() {
	while (true) {
		auto tkn = GetNextToken();

		switch (tkn.first) {
			case blitz::Lexer::Token::TokenNewLine:
			case blitz::Lexer::Token::TokenComment:
				// Skip Comments, since we don't really need them for the AST.
				continue;
			case blitz::Lexer::Token::TokenPlus:
			case blitz::Lexer::Token::TokenMinus:


			default: // End Of File / Unknown
			case blitz::Lexer::Token::TokenUnknown:
			case blitz::Lexer::Token::TokenEOF:
				return nullptr;
				break;
		}
	}
}

std::unique_ptr<blitz::AST::NumberExpression> blitz::parser::parse_number(blitz::Lexer::Token token, std::string value) {
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

	return std::make_unique<blitz::AST::NumberExpression>(parsed);
}

std::unique_ptr<blitz::AST::DecimalExpression> blitz::parser::parse_decimal(blitz::Lexer::Token token, std::string value) {
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

	return std::make_unique<blitz::AST::DecimalExpression>(parsed);
}
