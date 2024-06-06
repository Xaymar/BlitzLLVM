#include "value.hpp"

blitz::AST::VariableExpression::VariableExpression(std::string& name, ValueType type /*= ValueType::Number*/)
	: m_name(name), m_type(type) {}

blitz::AST::VariableExpression::~VariableExpression() {}

blitz::AST::ValueType blitz::AST::VariableExpression::GetType() {
	return m_type;
}

blitz::AST::NumberExpression::NumberExpression(int32_t value) : value(value) {}

blitz::AST::NumberExpression::~NumberExpression() {}

blitz::AST::ValueType blitz::AST::NumberExpression::GetType() {
	return ValueType::Number;
}

blitz::AST::DecimalExpression::DecimalExpression(float_t value) : value(value) {}

blitz::AST::DecimalExpression::~DecimalExpression() {}

blitz::AST::ValueType blitz::AST::DecimalExpression::GetType() {
	return ValueType::Decimal;
}

blitz::AST::StringExpression::StringExpression(std::string value) : value(value) {}

blitz::AST::StringExpression::~StringExpression() {}

blitz::AST::ValueType blitz::AST::StringExpression::GetType() {
	return ValueType::String;
}

blitz::AST::ConstExpression::ConstExpression(std::string& name, std::unique_ptr<ValueExpression> value)
	: m_name(name), m_value(std::move(value)) {}

blitz::AST::ConstExpression::~ConstExpression() {}

blitz::AST::ValueType blitz::AST::ConstExpression::GetType() {
	return m_value->GetType();
}
