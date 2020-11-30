#ifndef __CEXPR_BITCAST_
#define __CEXPR_BITCAST_

// borrowing this from the constexpr-builtin-bit-cast.cpp test from the SemaCXX
// tests, it doesn't apepar to be in libcxx yet. This will only work for Clang
// I'm not sure if there's a g++ equivelant.
template <class To, class From>
constexpr To cexpr_bit_cast(const From &from) {
  static_assert(sizeof(To) == sizeof(From));
  return __builtin_bit_cast(To, from);
}

#endif
