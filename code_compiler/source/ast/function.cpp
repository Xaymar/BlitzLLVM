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

#include "function.hpp"

BlitzLLVM::AST::ScopeExpression::ScopeExpression() {}

BlitzLLVM::AST::ScopeExpression::~ScopeExpression() {}

void BlitzLLVM::AST::ScopeExpression::AddExpression(std::unique_ptr<Expression> ex) {
	m_expressions.push_back(std::move(ex));
}

BlitzLLVM::AST::FunctionExpression::FunctionExpression(ValueType returnType,
	std::string& m_name,
	std::list<std::unique_ptr<VariableExpression>> parameters, 
	std::unique_ptr<ScopeExpression> scope)
	: m_returnType(returnType), m_name(m_name), m_parameters(std::move(parameters)), m_content(std::move(scope)) {

}

BlitzLLVM::AST::FunctionExpression::~FunctionExpression() {}

BlitzLLVM::AST::CallExpression::CallExpression(std::string& name, std::list<std::unique_ptr<VariableExpression>> arguments)
	: m_name(name), m_arguments(std::move(arguments)) {

}

BlitzLLVM::AST::CallExpression::~CallExpression() {}
