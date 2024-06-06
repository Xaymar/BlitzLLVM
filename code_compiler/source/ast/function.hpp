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
#include <list>
#include <memory>
#include <string>

namespace BlitzLLVM {
	namespace AST {
		class ScopeExpression : public Expression {
			public:
			ScopeExpression();
			virtual ~ScopeExpression();

			void AddExpression(std::unique_ptr<Expression> ex);

			private:
			std::list<std::unique_ptr<Expression>> m_expressions;
		};

		class FunctionExpression : public ScopeExpression {
			public:
			FunctionExpression(ValueType returnType,
				std::string& m_name,
				std::list<std::unique_ptr<VariableExpression>> parameters,
				std::unique_ptr<ScopeExpression> scope);
			virtual ~FunctionExpression();
			
			private:
			ValueType m_returnType;
			std::string m_name;
			std::list<std::unique_ptr<VariableExpression>> m_parameters;
			std::unique_ptr<ScopeExpression> m_content;
		};

		class CallExpression : public Expression {
			public:
			CallExpression(std::string& name, std::list<std::unique_ptr<VariableExpression>> arguments);
			virtual ~CallExpression();

			private:
			std::string m_name;
			std::list<std::unique_ptr<VariableExpression>> m_arguments;
		};

	}
}
