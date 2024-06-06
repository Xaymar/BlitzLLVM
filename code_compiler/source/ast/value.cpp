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

#include "value.hpp"

BlitzLLVM::AST::VariableExpression::VariableExpression(std::string& name, ValueType type /*= ValueType::Number*/)
	: m_name(name), m_type(type) {}

BlitzLLVM::AST::VariableExpression::~VariableExpression() {}

BlitzLLVM::AST::ValueType BlitzLLVM::AST::VariableExpression::GetType() {
	return m_type;
}

BlitzLLVM::AST::NumberExpression::NumberExpression(int32_t value) : value(value) {}

BlitzLLVM::AST::NumberExpression::~NumberExpression() {}

BlitzLLVM::AST::ValueType BlitzLLVM::AST::NumberExpression::GetType() {
	return ValueType::Number;
}

BlitzLLVM::AST::DecimalExpression::DecimalExpression(float_t value) : value(value) {}

BlitzLLVM::AST::DecimalExpression::~DecimalExpression() {}

BlitzLLVM::AST::ValueType BlitzLLVM::AST::DecimalExpression::GetType() {
	return ValueType::Decimal;
}

BlitzLLVM::AST::StringExpression::StringExpression(std::string value) : value(value) {}

BlitzLLVM::AST::StringExpression::~StringExpression() {}

BlitzLLVM::AST::ValueType BlitzLLVM::AST::StringExpression::GetType() {
	return ValueType::String;
}

BlitzLLVM::AST::ConstExpression::ConstExpression(std::string& name, std::unique_ptr<ValueExpression> value)
	: m_name(name), m_value(std::move(value)) {}

BlitzLLVM::AST::ConstExpression::~ConstExpression() {}

BlitzLLVM::AST::ValueType BlitzLLVM::AST::ConstExpression::GetType() {
	return m_value->GetType();
}
