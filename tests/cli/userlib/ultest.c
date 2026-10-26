// A userlib for the tests of blitzcc: functions the way a .decls file declares them.
#include <stdio.h>
#include <stdint.h>

#ifdef _WIN32
#define UL_EXPORT __declspec(dllexport)
#else
#define UL_EXPORT __attribute__((visibility("default")))
#endif

UL_EXPORT int32_t UlAdd(int32_t a, int32_t b)
{
	return a + b;
}

UL_EXPORT float UlScale(float value, float factor)
{
	return value * factor;
}

// Strings are returned from a buffer that is reused, like the original expects.
UL_EXPORT const char* UlGreet(const char* name)
{
	static char buffer[64];
	snprintf(buffer, sizeof(buffer), "hello, %s", name);
	return buffer;
}

UL_EXPORT void UlStore(int32_t* memory, int32_t value)
{
	*memory = value;
}

UL_EXPORT int32_t UlLoad(const int32_t* memory)
{
	return *memory;
}
