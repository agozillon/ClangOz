// Each of the sqrt functions are in their own file as they have different 
// copyright notices and it aligns with the way they're implemented in glibc!
// It's also the IEEE versions, so may not compare the same on systems like 
// SPARC which seem to have their own definitions.

#ifndef __CEXPR_SQRT_
#define __CEXPR_SQRT_

#include <cstdint>

// borrowing this from the constexpr-builtin-bit-cast.cpp test from the SemaCXX
// tests, it doesn't apepar to be in libcxx yet. This will only work for Clang
// I'm not sure if there's a g++ equivelant.
template <class To, class From>
constexpr To cexpr_bit_cast(const From &from) {
  static_assert(sizeof(To) == sizeof(From));
  return __builtin_bit_cast(To, from);
}

#include "cexpr_e_sqrtf.hpp" // float
#include "cexpr_e_sqrt.hpp"  // double
#include "cexpr_e_sqrtl.hpp" // long double

#endif
