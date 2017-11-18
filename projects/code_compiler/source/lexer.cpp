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

#include "lexer.hpp"
#include <codecvt>
#include <boost/algorithm/string/predicate.hpp>

std::pair<char, BlitzLLVM::Lexer::Token> g_symbolCharacters[] = {
	//{ '\"', BlitzLLVM::Lexer::Token::TokenDoubleQuote }, // Has special meaning.
	{ '+', BlitzLLVM::Lexer::Token::TokenPlus },
	{ '-', BlitzLLVM::Lexer::Token::TokenMinus },
	{ '/', BlitzLLVM::Lexer::Token::TokenSlashForward },
	{ '\\', BlitzLLVM::Lexer::Token::TokenSlashBackward },
	{ '*', BlitzLLVM::Lexer::Token::TokenMultiply },
	{ '=', BlitzLLVM::Lexer::Token::TokenEqual },
	{ '#', BlitzLLVM::Lexer::Token::TokenOctothorp },
	{ '%', BlitzLLVM::Lexer::Token::TokenPercent },
	{ '$', BlitzLLVM::Lexer::Token::TokenDollar },
	{ '(', BlitzLLVM::Lexer::Token::TokenRoundBracketOpen },
	{ ')', BlitzLLVM::Lexer::Token::TokenRoundBracketClose },
	{ '[', BlitzLLVM::Lexer::Token::TokenSquareBracketOpen },
	{ ']', BlitzLLVM::Lexer::Token::TokenSquareBracketClose },
	{ '<', BlitzLLVM::Lexer::Token::TokenAngleBracketOpen },
	{ '>', BlitzLLVM::Lexer::Token::TokenAngleBracketClose },
	//{ '.', BlitzLLVM::Lexer::Token::TokenDot }, // Special meaning.
	{ ':', BlitzLLVM::Lexer::Token::TokenColon },
	{ ',', BlitzLLVM::Lexer::Token::TokenComma },
	//{ ';', BlitzLLVM::Lexer::Token::TokenSemicolon },
	{ '^', BlitzLLVM::Lexer::Token::TokenCaret },
	{ '~', BlitzLLVM::Lexer::Token::TokenBitNot },
};

BlitzLLVM::Lexer::Lexer(std::istream& fs) : m_fileStream(fs) {}

BlitzLLVM::Lexer::~Lexer() {}

std::pair<BlitzLLVM::Lexer::Token, std::string> BlitzLLVM::Lexer::GetNextToken() {
	std::string buf;
	Token tkn = Token::TokenEOF;
	bool haveResult = false;

	// Allow "overriding" the next retrieved Token.
	if (m_overrideToken != Token::TokenUnknown) {
		buf = m_overrideText;
		tkn = m_overrideToken;
		m_overrideToken = Token::TokenUnknown;
		haveResult = true;
	}

	while (((m_fileStream.eof() == false) && (m_fileStream.good())) && !haveResult) {
		char chr = m_fileStream.get();

		if (chr == '\r' || chr == '\n') {
			if (tkn != Token::TokenEOF) {
				m_overrideToken = Token::TokenNewLine;
				m_overrideText = "";
			} else {
				tkn = Token::TokenNewLine;
				buf = "";
			}

			m_isStringMode = false;
			m_isNumberMode = false;
			m_isTextMode = false;
			m_isCommentMode = false;
			break;
		} else if (m_isStringMode) {
			if (chr == '\"') {
				m_overrideToken = Token::TokenDoubleQuote;
				m_overrideText = chr;
				m_isStringMode = false;
				tkn = Token::TokenQuotedText;
				break;
			} else if (iscntrl(chr) || !isprint(chr)) {
				m_fileStream.putback(chr);
				m_isStringMode = false;
				break;
			} else {
				buf += chr;
			}
		} else if (m_isTextMode) {
			if (isalnum(chr) || (chr == '_')) {
				buf += chr;
			} else {
				m_fileStream.putback(chr);
				m_isTextMode = false;
				break;
			}
		} else if (m_isNumberMode) {
			if (isdigit(chr)) {
				buf += chr;
			} else if (chr == '.') {
				if (m_numberModeHasDecimal == false) {
					m_numberModeHasDecimal = true;
					tkn = Token::TokenDecimal;
					buf += chr;
				} else {
					m_fileStream.putback(chr);
					m_isNumberMode = false;
					break;
				}
			} else {
				m_fileStream.putback(chr);
				m_isNumberMode = false;
				break;
			}
		} else if (m_isCommentMode) {
			buf += chr;
			tkn = Token::TokenComment;
		} else {
			// Whitespace
			if (isspace(chr))
				continue;

			// Control Code
			if (iscntrl(chr)) {
				tkn = Token::TokenUnknown;
				buf = chr;
			}

			// Symbol
			for (auto v : g_symbolCharacters) {
				if (v.first == chr) {
					tkn = v.second;
					buf = v.first;
					break;
				}
			}
			if (tkn != Token::TokenEOF) {
				haveResult = true;
				break;
			}

			// Strings, Text, Numbers
			if (chr == ';') {
				m_isCommentMode = true;
				tkn = Token::TokenSemicolon;
				buf = chr;
				break;
			} else if (chr == '\"') {
				m_isStringMode = true;
				tkn = Token::TokenDoubleQuote;
				buf = chr;
				break;
			} else if (isalpha(chr)) {
				m_isTextMode = true;
				tkn = Token::TokenText;
				buf = chr;
			} else if (isdigit(chr)) {
				m_isNumberMode = true;
				m_numberModeHasDecimal = false;
				tkn = Token::TokenNumber;
				buf = chr;
			} else if (chr == '.') {
				m_isNumberMode = true;
				m_numberModeHasDecimal = true;
				tkn = Token::TokenDecimal;
				buf = "0" + chr;
			} else {
				tkn = Token::TokenUnknown;
				buf = chr;
				break;
			}
		}
	}

	// Convert from Text into native Token.
	if (tkn == Token::TokenText)
		tkn = ConvertTextToToken(tkn, buf);

	return std::make_pair(tkn, buf);
}

BlitzLLVM::Lexer::Token BlitzLLVM::Lexer::ConvertTextToToken(Token in, std::string text) {
	static std::pair<const char*, Token> l_textToTokenList[] = {
		// Binary
		{ "not", Token::TokenNot },
		{ "and", Token::TokenAnd },
		{ "or", Token::TokenOr },
		{ "xor", Token::TokenXor },
		{ "shl", Token::TokenShl },
		{ "shr", Token::TokenShr },
		{ "sal", Token::TokenSal },
		{ "sar", Token::TokenSar },
		{ "false", Token::TokenFalse },
		{ "true", Token::TokenTrue },

		// Conversion
		{ "float", Token::TokenFloat },
		{ "string", Token::TokenString },
		{ "hex", Token::TokenHex },
		{ "int", Token::TokenInt },

		// Control
		{ "if", Token::TokenIf },
		{ "then", Token::TokenThen },
		{ "elseIf", Token::TokenElseIf },
		{ "else", Token::TokenElse },
		{ "endIf", Token::TokenEndIf },
		{ "select", Token::TokenSelect },
		{ "case", Token::TokenCase },
		{ "default", Token::TokenDefault },
		{ "goto", Token::TokenGoto },
		{ "gosub", Token::TokenGosub },
		{ "return", Token::TokenReturn },
		{ "function", Token::TokenFunction },
		{ "end", Token::TokenEnd },
		{ "stop", Token::TokenStop },
		
		// Loop
		{ "for", Token::TokenFor },
		{ "to", Token::TokenTo },
		{ "next", Token::TokenNext },
		{ "while", Token::TokenWhile },
		{ "wend", Token::TokenWend },
		{ "repeat", Token::TokenRepeat },
		{ "until", Token::TokenUntil },
		{ "forever", Token::TokenForever },
		{ "exit", Token::TokenExit },

		// Math
		{ "abs", Token::TokenAbs },
		{ "sign", Token::TokenSign },
		{ "cos", Token::TokenCos },
		{ "sin", Token::TokenSin },
		{ "tan", Token::TokenTan },
		{ "acos", Token::TokenACos },
		{ "asin", Token::TokenASin },
		{ "atan", Token::TokenATan },
		{ "atan2", Token::TokenATan2 },
		{ "log", Token::TokenLog },
		{ "log10", Token::TokenLog10 },
		{ "ceil", Token::TokenCeil },
		{ "floor", Token::TokenFloor },
		{ "mod", Token::TokenMod },
		{ "pi", Token::TokenPi },
		{ "exp", Token::TokenExp },
		{ "sqr", Token::TokenSqr },

		// Variables
		{ "const", Token::TokenConst },
		{ "global", Token::TokenGlobal },
		{ "local", Token::TokenLocal },

		// Includes
		{ "include", Token::TokenInclude },
	};
	for (auto v : l_textToTokenList) {
		if (boost::iequals(text, v.first)) {
			return v.second;
		}
	}
	return in;
}
