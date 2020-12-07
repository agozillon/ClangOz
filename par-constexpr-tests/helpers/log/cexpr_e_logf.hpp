/* Configuration for double precision math routines.
   Copyright (C) 2018-2020 Free Software Foundation, Inc.
   This file is part of the GNU C Library.

   The GNU C Library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) any later version.

   The GNU C Library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with the GNU C Library; if not, see
   <https://www.gnu.org/licenses/>.  */

#ifndef __CEXPR_E_LOGF_
#define __CEXPR_E_LOGF_

#include "../cexpr_math_helpers.hpp"
#include "cexpr_e_logf_data.hpp"

// This file contains all the code segments from glibc required to make 
// the double variation of the IEEE754 e_logf.c file from glibc constexpr!

#define LOGF_TABLE_BITS 4
#define LOGF_POLY_ORDER 4
#define T __logf_data.tab
#define A __logf_data.poly
#define Ln2 __logf_data.ln2
#define N (1 << LOGF_TABLE_BITS)
#define OFF 0x3f330000

constexpr float cexpr_logf(float x) {
  /* double_t for better performance on targets with FLT_EVAL_METHOD==2.  */
  double_t z = 0, r = 0, r2 = 0, y = 0, y0 = 0, invc = 0, logc = 0;
  uint32_t ix = 0, iz = 0, tmp = 0;
  int k = 0, i = 0;

  ix = asuint(x);
#if WANT_ROUNDING
  /* Fix sign of zero with downward rounding when x==1.  */
  if (__glibc_unlikely (ix == 0x3f800000))
    return 0;
#endif
  if (__glibc_unlikely (ix - 0x00800000 >= 0x7f800000 - 0x00800000))
    {
      /* x < 0x1p-126 or inf or nan.  */
      if (ix * 2 == 0)
        return -1 / 0; // __math_divzerof (1);
      if (ix == 0x7f800000) /* log(inf) == inf.  */
        return x;
      if ((ix & 0x80000000) || ix * 2 >= 0xff000000)
        return (x - x) / (x - x); // __math_invalidf (x);

      /* x is subnormal, normalize it.  */
      ix = asuint (x * 0x1p23f);
      ix -= 23 << 23;
    }

  /* x = 2^k z; where z is in range [OFF,2*OFF] and exact.
     The range is split into N subintervals.
     The ith subinterval contains z and c is near its center.  */
  tmp = ix - OFF;
  i = (tmp >> (23 - LOGF_TABLE_BITS)) % N;
  k = static_cast<int32_t>(tmp) >> 23; /* arithmetic shift */
  iz = ix - (tmp & 0x1ff << 23);
  invc = T[i].invc;
  logc = T[i].logc;
  z = static_cast<double_t>(asfloat (iz));

  /* log(x) = log1p(z/c-1) + log(c) + k*Ln2 */
  r = z * invc - 1;
  y0 = logc + static_cast<double_t>(k) * Ln2;

  /* Pipelined polynomial evaluation to approximate log1p(r).  */
  r2 = r * r;
  y = A[1] * r + A[2];
  y = A[0] * r2 + y;
  y = y * r2 + (y0 + r);
  return static_cast<float>(y);
}

#undef LOGF_TABLE_BITS
#undef LOGF_POLY_ORDER
#undef T
#undef A
#undef Ln2
#undef N
#undef OFF

#endif
