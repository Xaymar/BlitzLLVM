#include "arithmetic.hpp"

blitz::AST::ArithmeticExpression::ArithmeticExpression(Operator op, std::unique_ptr<Expression> left, std::unique_ptr<Expression> right)
	: m_operator(op), m_left(std::move(left)), m_right(std::move(right)) {}

blitz::AST::ArithmeticExpression::~ArithmeticExpression() {}
