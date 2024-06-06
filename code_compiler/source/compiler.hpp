#pragma once
#include <string>

namespace blitz {
	class compiler {
		public:
		compiler();
		~compiler();

		bool compile(std::string in, std::string out);
	};
}
