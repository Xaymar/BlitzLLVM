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

#include "arithmetic.hpp"

BlitzLLVM::AST::ArithmeticExpression::ArithmeticExpression(Operator op, std::unique_ptr<Expression> left, std::unique_ptr<Expression> right)
	: m_operator(op), m_left(std::move(left)), m_right(std::move(right)) {}

BlitzLLVM::AST::ArithmeticExpression::~ArithmeticExpression() {}
