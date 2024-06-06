#pragma once
#include "ast.hpp"
#include "value.hpp"

namespace blitz {
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