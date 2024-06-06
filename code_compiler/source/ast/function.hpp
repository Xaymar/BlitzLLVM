#pragma once
#include "ast.hpp"
#include "value.hpp"
#include <list>
#include <memory>
#include <string>

namespace blitz {
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
