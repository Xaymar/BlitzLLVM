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
#include <list>
#include <istream>
#include <string>
#include <inttypes.h>

namespace BlitzLLVM {	
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

			// Binary
			TokenNot,
			TokenAnd, TokenOr, TokenXor,
			TokenShl, TokenShr,
			TokenSar, TokenSal,
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
		Lexer(std::istream& fs);
		~Lexer();

		std::pair<Token, std::string> GetNextToken();
		
		private:
		std::istream& m_fileStream;

		bool m_isTextMode = false;
		bool m_isNumberMode = false;
		bool m_isStringMode = false;
		bool m_numberModeHasDecimal = false;

		Token m_overrideToken = Token::TokenUnknown;
		std::string m_overrideText = "";
	};
}