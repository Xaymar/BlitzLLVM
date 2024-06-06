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
#include "lexer.hpp"
#include <inttypes.h>
#include <float.h>
#include <math.h>
#include <memory>
#include <string>

namespace BlitzLLVM {
	namespace AST {
		enum class ValueType : int8_t {
			Unknown,
			Number,
			Decimal,
			String,
			Type,
		};

		class ValueExpression : public Expression {
			public:
			virtual ValueType GetType() = 0;
		};

		class ConstExpression : public ValueExpression {
			public:
			ConstExpression(std::string& name, std::unique_ptr<ValueExpression> value);
			virtual ~ConstExpression();

			virtual ValueType GetType() override;

			private:
			std::string m_name;
			std::unique_ptr<ValueExpression> m_value;
		};

		class VariableExpression : public ValueExpression {
			public:
			VariableExpression(std::string& name, ValueType type = ValueType::Number);
			virtual ~VariableExpression();

			virtual ValueType GetType() override;

			private:
			std::string m_name;
			ValueType m_type;
		};

		class NumberExpression : public ValueExpression {
			public:
			NumberExpression(int32_t value);
			virtual ~NumberExpression();

			virtual ValueType GetType() override;

			private:
			int32_t value;
		};

		class DecimalExpression : public ValueExpression {
			public:
			DecimalExpression(float_t value);
			virtual ~DecimalExpression();

			virtual ValueType GetType() override;

			private:
			float_t value;
		};

		class StringExpression : public ValueExpression {
			public:
			StringExpression(std::string value);
			virtual ~StringExpression();

			virtual ValueType GetType() override;

			private:
			std::string value;
		};
	}
}