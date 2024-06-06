#pragma once
#include "lexer.hpp"
#include "ast/ast.hpp"
#include "ast/value.hpp"
#include <fstream>
#include <map>
#include <memory>
#include <string>
#include <stack>

namespace blitz {
	class parser {
		public:
		parser(std::string file);
		~parser();

		std::unique_ptr<AST::Expression> Parse();

		protected:
		void LogMessage(const char* msg, ...);
		void LogError(const char* msg, ...);

		private:
		std::pair<blitz::Lexer::Token, std::string> GetNextToken();

		private:
		std::unique_ptr<AST::Expression> parse_expression();
		std::unique_ptr<AST::NumberExpression> parse_number(blitz::Lexer::Token token, std::string value);
		std::unique_ptr<AST::DecimalExpression> parse_decimal(blitz::Lexer::Token token, std::string value);

		private:
		Lexer m_lexer;
		std::stack<std::pair<std::string, std::shared_ptr<std::istream>>> m_files;

	};
}
