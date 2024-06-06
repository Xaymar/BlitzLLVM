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
#include "ast.hpp"
#include "value.hpp"

namespace BlitzLLVM {
	namespace AST {
		enum class Operator : int8_t {
			Add, /*+*/
			Subtract, /*-*/
			Multiply, /***/
			Divide, /*/*/
			Invert, /*~*/
			Power, /*^*/
			Equal, /*=*/
		};

		class ArithmeticExpression : public Expression {
			public:
			ArithmeticExpression(Operator op, std::unique_ptr<Expression> left, std::unique_ptr<Expression> right);
			virtual ~ArithmeticExpression();

			private:
			Operator m_operator;
			std::unique_ptr<Expression> m_left, m_right;
		};
	}
}