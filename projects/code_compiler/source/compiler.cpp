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
	std::ifstream infile;
	infile.open(in);
	if (infile.bad() || !infile.good() || infile.eof()) {
		std::cerr << "Failed to open file: " << in << std::endl;
		return false;
	}

	Lexer psr = { infile };
	for (auto tkn = psr.GetNextToken(); tkn.first != Lexer::Token::TokenEOF; tkn = psr.GetNextToken()) {
		switch (tkn.first) {
			case Lexer::Token::TokenEOF:
				std::cout << "EOF" << std::endl;
				break;
			case Lexer::Token::TokenNewLine:
				std::cout << "" << std::endl;
				break;
			case Lexer::Token::TokenPlus:
			case Lexer::Token::TokenMinus:
			case Lexer::Token::TokenSlashForward:
			case Lexer::Token::TokenSlashBackward:
			case Lexer::Token::TokenMultiply:
			case Lexer::Token::TokenEqual:
			case Lexer::Token::TokenOctothorp:
			case Lexer::Token::TokenPercent:
			case Lexer::Token::TokenDollar:
			case Lexer::Token::TokenRoundBracketOpen:
			case Lexer::Token::TokenRoundBracketClose:
			case Lexer::Token::TokenSquareBracketOpen:
			case Lexer::Token::TokenSquareBracketClose:
			case Lexer::Token::TokenAngleBracketOpen:
			case Lexer::Token::TokenAngleBracketClose:
			case Lexer::Token::TokenDot:
			case Lexer::Token::TokenColon:
			case Lexer::Token::TokenComma:
			case Lexer::Token::TokenSemicolon:
			case Lexer::Token::TokenCaret:
			case Lexer::Token::TokenBitNot:
			case Lexer::Token::TokenDoubleQuote:
			case Lexer::Token::TokenNot:
			case Lexer::Token::TokenAnd:
			case Lexer::Token::TokenOr:
			case Lexer::Token::TokenXor:
			case Lexer::Token::TokenShl:
			case Lexer::Token::TokenShr:
			case Lexer::Token::TokenSal:
			case Lexer::Token::TokenFalse:
			case Lexer::Token::TokenTrue:
			case Lexer::Token::TokenFloat:
			case Lexer::Token::TokenString:
			case Lexer::Token::TokenHex:
			case Lexer::Token::TokenInt:
			case Lexer::Token::TokenIf:
			case Lexer::Token::TokenThen:
			case Lexer::Token::TokenElseIf:
			case Lexer::Token::TokenElse:
			case Lexer::Token::TokenEndIf:
			case Lexer::Token::TokenSelect:
			case Lexer::Token::TokenCase:
			case Lexer::Token::TokenDefault:
			case Lexer::Token::TokenGoto:
			case Lexer::Token::TokenGosub:
			case Lexer::Token::TokenReturn:
			case Lexer::Token::TokenFunction:
			case Lexer::Token::TokenEnd:
			case Lexer::Token::TokenStop:
			case Lexer::Token::TokenFor:
			case Lexer::Token::TokenTo:
			case Lexer::Token::TokenNext:
			case Lexer::Token::TokenWhile:
			case Lexer::Token::TokenWend:
			case Lexer::Token::TokenRepeat:
			case Lexer::Token::TokenUntil:
			case Lexer::Token::TokenForever:
			case Lexer::Token::TokenExit:
			case Lexer::Token::TokenAbs:
			case Lexer::Token::TokenSign:
			case Lexer::Token::TokenCos:
			case Lexer::Token::TokenSin:
			case Lexer::Token::TokenTan:
			case Lexer::Token::TokenACos:
			case Lexer::Token::TokenASin:
			case Lexer::Token::TokenATan:
			case Lexer::Token::TokenATan2:
			case Lexer::Token::TokenLog:
			case Lexer::Token::TokenLog10:
			case Lexer::Token::TokenCeil:
			case Lexer::Token::TokenFloor:
			case Lexer::Token::TokenMod:
			case Lexer::Token::TokenPi:
			case Lexer::Token::TokenExp:
			case Lexer::Token::TokenSqr:
			case Lexer::Token::TokenConst:
			case Lexer::Token::TokenGlobal:
			case Lexer::Token::TokenLocal:
			case Lexer::Token::TokenInclude:
				std::cout << tkn.second << ' ';
				break;
			case Lexer::Token::TokenText:
				std::cout << "Text(" << tkn.second << ")" << ' ';
				break;
			case Lexer::Token::TokenNumber:
				std::cout << "Number(" << tkn.second << ")" << ' ';
				break;
			case Lexer::Token::TokenDecimal:
				std::cout << "Decimal(" << tkn.second << ")" << ' ';
				break;
			case Lexer::Token::TokenQuotedText:
				std::cout << "QuotedText(" << tkn.second << ")" << ' ';
				break;
			case Lexer::Token::TokenComment:
				std::cout << "Comment(" << tkn.second << ")" << ' ';
				break;
			case Lexer::Token::TokenUnknown:
			default:
				std::cout << "Unknown(" << tkn.second << ") ";
				break;
		}
	}

	return true;
}
