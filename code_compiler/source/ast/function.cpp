#include "function.hpp"

blitz::AST::ScopeExpression::ScopeExpression() {}

blitz::AST::ScopeExpression::~ScopeExpression() {}

void blitz::AST::ScopeExpression::AddExpression(std::unique_ptr<Expression> ex) {
	m_expressions.push_back(std::move(ex));
}

blitz::AST::FunctionExpression::FunctionExpression(ValueType returnType,
	std::string& m_name,
	std::list<std::unique_ptr<VariableExpression>> parameters, 
	std::unique_ptr<ScopeExpression> scope)
	: m_returnType(returnType), m_name(m_name), m_parameters(std::move(parameters)), m_content(std::move(scope)) {

}

blitz::AST::FunctionExpression::~FunctionExpression() {}

blitz::AST::CallExpression::CallExpression(std::string& name, std::list<std::unique_ptr<VariableExpression>> arguments)
	: m_name(name), m_arguments(std::move(arguments)) {

}

blitz::AST::CallExpression::~CallExpression() {}
