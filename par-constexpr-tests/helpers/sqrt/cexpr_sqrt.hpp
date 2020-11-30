// Each of the sqrt functions are in their own file as they have different 
// copyright notices and it aligns with the way they're implemented in glibc!
// It's also the IEEE versions, so may not compare the same on systems like 
// SPARC which seem to have their own definitions.

#ifndef __CEXPR_SQRT_
#define __CEXPR_SQRT_

#include <cstdint>

#include "../cexpr_bitcast.hpp"
#include "cexpr_e_sqrtf.hpp" // float
#include "cexpr_e_sqrt.hpp"  // double
#include "cexpr_e_sqrtl.hpp" // long double

#endif
