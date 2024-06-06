#pragma once
#include <inttypes.h>
#include <istream>
#include <memory>
#include <string>
#include <utility>

namespace blitz {	
	class Lexer {
		public:
		enum class Token : uint64_t {
			TokenUnknown,
			TokenEOF,
			TokenNewLine,

			// Symbols
			TokenPlus,
			TokenMinus,
			TokenSlashForward,
			TokenSlashBackward,
			TokenMultiply,
			TokenEqual,
			TokenOctothorp,
			TokenPercent,
			TokenDollar,
			TokenRoundBracketOpen,
			TokenRoundBracketClose,
			TokenSquareBracketOpen,
			TokenSquareBracketClose,
			TokenAngleBracketOpen,
			TokenAngleBracketClose,
			TokenDot,
			TokenColon,
			TokenComma,
			TokenSemicolon,
			TokenCaret,
			TokenBitNot /*~*/,

			// String Delimiter
			TokenDoubleQuote,

			// Types
			TokenText,
			TokenNumber,
			TokenDecimal,
			TokenQuotedText, // Text encapsulated by TokenDoubleQuote
			TokenComment,

			// Binary
			TokenNot,
			TokenAnd, TokenOr, TokenXor,
			TokenShl, TokenShr,
			TokenSal, TokenSar,
			TokenFalse, TokenTrue,

			// Conversion
			TokenFloat,
			TokenString, TokenHex,
			TokenInt,

			// Control
			TokenIf, TokenThen, TokenElseIf, TokenElse, TokenEndIf,
			TokenSelect, TokenCase, TokenDefault, // End Select = TokenEnd, TokenSelect.
			TokenGoto, TokenGosub,
			TokenReturn,
			TokenFunction, // End Function = TokenEnd, TokenFunction.
			TokenEnd,
			TokenStop /* DEBUGGER! Ignore in Release mode. */,

			// Loop
			TokenFor, TokenTo, TokenNext,
			TokenWhile, TokenWend,
			TokenRepeat, TokenUntil, TokenForever,
			TokenExit,

			// Math
			TokenAbs, TokenSign /*Sgn*/,
			TokenCos, TokenSin, TokenTan,
			TokenACos, TokenASin, TokenATan, TokenATan2,
			TokenLog, TokenLog10,
			TokenCeil, TokenFloor,
			TokenMod,
			TokenPi,
			TokenExp, TokenSqr,

			// Variables
			TokenConst,
			TokenGlobal,
			TokenLocal,

			// Including files.
			TokenInclude,
		};

		public:
		Lexer();
		~Lexer();

		std::pair<Token, std::string> GetCurrentToken();
		std::pair<Token, std::string> GetNextToken(std::shared_ptr<std::istream> fs);
		
		private:
		blitz::Lexer::Token ConvertTextToToken(Token in, std::string text);

		private:
		Token m_currentToken = Token::TokenUnknown;
		std::string m_currentText = "";
		Token m_overrideToken = Token::TokenUnknown;
		std::string m_overrideText = "";
	};
}
