#include "lexer.hpp"
#include <codecvt>

std::pair<char, blitz::Lexer::Token> g_symbolCharacters[] = {
	//{ '\"', BlitzLLVM::Lexer::Token::TokenDoubleQuote }, // Has special meaning.
	{ '+', blitz::Lexer::Token::TokenPlus },
	{ '-', blitz::Lexer::Token::TokenMinus },
	{ '/', blitz::Lexer::Token::TokenSlashForward },
	{ '\\', blitz::Lexer::Token::TokenSlashBackward },
	{ '*', blitz::Lexer::Token::TokenMultiply },
	{ '=', blitz::Lexer::Token::TokenEqual },
	{ '#', blitz::Lexer::Token::TokenOctothorp },
	{ '%', blitz::Lexer::Token::TokenPercent },
	{ '$', blitz::Lexer::Token::TokenDollar },
	{ '(', blitz::Lexer::Token::TokenRoundBracketOpen },
	{ ')', blitz::Lexer::Token::TokenRoundBracketClose },
	{ '[', blitz::Lexer::Token::TokenSquareBracketOpen },
	{ ']', blitz::Lexer::Token::TokenSquareBracketClose },
	{ '<', blitz::Lexer::Token::TokenAngleBracketOpen },
	{ '>', blitz::Lexer::Token::TokenAngleBracketClose },
	//{ '.', BlitzLLVM::Lexer::Token::TokenDot }, // Special meaning.
	{ ':', blitz::Lexer::Token::TokenColon },
	{ ',', blitz::Lexer::Token::TokenComma },
	//{ ';', BlitzLLVM::Lexer::Token::TokenSemicolon },
	{ '^', blitz::Lexer::Token::TokenCaret },
	{ '~', blitz::Lexer::Token::TokenBitNot },
};

blitz::Lexer::Lexer() {}

blitz::Lexer::~Lexer() {}

std::pair<blitz::Lexer::Token, std::string> blitz::Lexer::GetCurrentToken() {
	return std::make_pair(m_currentToken, m_currentText);
}

std::pair<blitz::Lexer::Token, std::string> blitz::Lexer::GetNextToken(std::shared_ptr<std::istream> fs) {
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

	bool m_isTextMode = false;
	bool m_isNumberMode = false;
	bool m_isStringMode = false;
	bool m_isCommentMode = false;
	bool m_numberModeHasDecimal = false;
	while (((fs->eof() == false) && (fs->good())) && !haveResult) {
		char chr = fs->get();

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
				fs->putback(chr);
				m_isStringMode = false;
				break;
			} else {
				buf += chr;
			}
		} else if (m_isTextMode) {
			if (isalnum(chr) || (chr == '_')) {
				buf += chr;
			} else {
				fs->putback(chr);
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
					fs->putback(chr);
					m_isNumberMode = false;
					break;
				}
			} else {
				fs->putback(chr);
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

			// Special handling for + and -, due to numbers and decimals.
			if (chr == '+' || chr == '-') {
				char chr2 = fs->get();
				if (isdigit(chr2)) {
					m_isNumberMode = true;
					m_numberModeHasDecimal = false;
					tkn = Token::TokenNumber;
					buf = chr + chr2;
					break;
				} else if (chr2 == '.') {
					m_isNumberMode = true;
					m_numberModeHasDecimal = true;
					tkn = Token::TokenDecimal;
					buf = chr + "0" + chr2;
					break;
				} else {
					fs->putback(chr2);
				}
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

blitz::Lexer::Token blitz::Lexer::ConvertTextToToken(Token in, std::string text) {
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
