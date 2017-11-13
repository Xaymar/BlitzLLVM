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

char g_whitespaceCharacters[] = {
	' ',
	'\t',
};

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
	{ ';', BlitzLLVM::Lexer::Token::TokenSemicolon },
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
			break;
		} else if (!m_isStringMode && !m_isTextMode && !m_isNumberMode) {
			// Whitespace
			bool isWhitespace = false;
			for (char v : g_whitespaceCharacters) {
				if (v == chr) {
					isWhitespace = true;
					break;
				}
			}
			if (isWhitespace)
				continue;

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
			if (chr == '\"') {
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
		} else if (m_isStringMode) {
			if (chr == '\"') {
				m_overrideToken = Token::TokenDoubleQuote;
				m_overrideText = chr;
				m_isStringMode = false;
				tkn = Token::TokenQuotedText;
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
					throw std::runtime_error("Unexpected '.' while parsing number.");
				}
			} else {
				m_fileStream.putback(chr);
				m_isNumberMode = false;
				break;				
			}
		}
	}

	return std::make_pair(tkn, buf);
}
