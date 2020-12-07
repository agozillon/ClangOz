#ifndef __CEXPR_MATH_HELPERS_
#define __CEXPR_MATH_HELPERS_

#include "cexpr_bitcast.hpp"

/*
 * IBM Accurate Mathematical Library
 * written by International Business Machines Corp.
 * Copyright (C) 2001-2020 Free Software Foundation, Inc.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; either version 2.1 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, see <https://www.gnu.org/licenses/>.
 */

  static constexpr uint32_t asuint(float f) {
    return cexpr_bit_cast<uint32_t>(f);
  }

  static constexpr float asfloat(uint32_t i) {
    return cexpr_bit_cast<float>(i);
  }
  
  static constexpr uint64_t asuint64(double f) {
    return cexpr_bit_cast<uint64_t>(f);
  }

  static constexpr double asdouble(uint64_t i) {
    return cexpr_bit_cast<double>(i);
  }

  /* Top 12 bits of a double (sign and exponent bits).  */
  static constexpr uint32_t top12(double x) {
    return asuint64 (x) >> 52;
  }

  static constexpr uint32_t top12(float x) {
    return asuint(x) >> 20;
  }

  /* Top 16 bits of a double.  */
  static constexpr uint32_t top16(double x) {
    return asuint64(x) >> 48;
  }

  constexpr int cexpr_isnanf(float x) {
    int32_t ix = asuint(x);
    ix &= 0x7fffffff;
    ix = 0x7f800000 - ix;
    return static_cast<int>(static_cast<uint32_t>(ix)>>31);
  }

#endif
