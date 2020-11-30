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
#ifndef __CEXPR_E_LOG_
#define __CEXPR_E_LOG_

#include "../cexpr_math_helpers.hpp"
#include "cexpr_e_log_data.hpp"

#define LOG_TABLE_BITS 7

#define T __log_data.tab
#define T2 __log_data.tab2
#define B __log_data.poly1
#define A __log_data.poly
#define Ln2hi __log_data.ln2hi
#define Ln2lo __log_data.ln2lo
#define N (1 << LOG_TABLE_BITS)
#define OFF 0x3fe6000000000000

#define WANT_ROUNDING 1

// This file contains all the code segments from glibc required to make 
// the double variation of the IEEE754 e_log.c file from glibc constexpr!

double constexpr cexpr_log(double x)
{
  /* double_t for better performance on targets with FLT_EVAL_METHOD==2.  */
  double_t w = 0, z = 0, r = 0, r2 = 0, r3 = 0, y = 0, invc = 0, logc = 0, 
           kd = 0, hi = 0, lo = 0;
  uint64_t ix = 0, iz = 0, tmp = 0;
  uint32_t top = 0;
  int k = 0, i = 0;

  ix = asuint64(x);
  top = top16(x);

#define LO asuint64 (1.0 - 0x1p-4)
#define HI asuint64 (1.0 + 0x1.09p-4)
  if (__glibc_unlikely (ix - LO < HI - LO))
    {
      /* Handle close to 1.0 inputs separately.  */
      /* Fix sign of zero with downward rounding when x==1.  */
      if (WANT_ROUNDING && __glibc_unlikely (ix == asuint64 (1.0)))
	return 0;
      r = x - 1.0;
      r2 = r * r;
      r3 = r * r2;
      y = r3 * (B[1] + r * B[2] + r2 * B[3]
		+ r3 * (B[4] + r * B[5] + r2 * B[6]
			+ r3 * (B[7] + r * B[8] + r2 * B[9] + r3 * B[10])));
      /* Worst-case error is around 0.507 ULP.  */
      w = r * 0x1p27;
      double_t rhi = r + w - w;
      double_t rlo = r - rhi;
      w = rhi * rhi * B[0]; /* B[0] == -0.5.  */
      hi = r + w;
      lo = r - hi + w;
      lo += B[0] * rlo * (rhi + r);
      y += lo;
      y += hi;
      return y;
    }
  if (__glibc_unlikely (top - 0x0010 >= 0x7ff0 - 0x0010))
    {
      
      // this was an error function __math_divzero, which forces the divide by 0
      // below with a sign change depending on the input value and the setting 
      // of an error (it's also tied to some assembly). This WILL result
      // in a compile time error as it's a divide by 0. But this is generally
      // an error condition / undefined behaviour so i think it should be ok.
      /* x < 0x1p-1022 or inf or nan.  */
      if (ix * 2 == 0)
        return -1.0 / 0.0; // __math_divzero (1);
      if (ix == asuint64 (INFINITY)) /* log(inf) == inf.  */
        return x;

      // this was an error function __math_invalid that sets
      // an error number and returns a value of x - x / x - x (it's also tied 
      // to some assembly), however if I try to do that, it will result in a 
      // divide by 0 which is illegal at compile time! I'm leaving it in for the
      // moment though as this is generally indicating undesirable behaviour.. 
      // we'll see how that plays out
      if ((top & 0x8000) || (top & 0x7ff0) == 0x7ff0)
        return x - x / x - x;  // __math_invalid (x);
      /* x is subnormal, normalize it.  */
      ix = asuint64 (x * 0x1p52);
      ix -= 52ULL << 52;
    }

  /* x = 2^k z; where z is in range [OFF,2*OFF) and exact.
     The range is split into N subintervals.
     The ith subinterval contains z and c is near its center.  */
  tmp = ix - OFF;
  i = (tmp >> (52 - LOG_TABLE_BITS)) % N;
  k = (int64_t) tmp >> 52; /* arithmetic shift */
  iz = ix - (tmp & 0xfffULL << 52);
  invc = T[i].invc;
  logc = T[i].logc;
  z = asdouble (iz);

  /* log(x) = log1p(z/c-1) + log(c) + k*Ln2.  */
  /* r ~= z/c - 1, |r| < 1/(2*N).  */

  /* rounding error: 0x1p-55/N + 0x1p-66.  */
  r = (z - T2[i].chi - T2[i].clo) * invc;

  kd = (double_t) k;

  /* hi + lo = r + log(c) + k*Ln2.  */
  w = kd * Ln2hi + logc;
  hi = w + r;
  lo = w - hi + r + kd * Ln2lo;

  /* log(x) = lo + (log1p(r) - r) + hi.  */
  r2 = r * r; /* rounding error: 0x1p-54/N^2.  */
  /* Worst case error if |y| > 0x1p-4: 0.519 ULP (0.520 ULP without fma).
     0.5 + 2.06/N + abs-poly-error*2^56 ULP (+ 0.001 ULP without fma).  */
  y = lo + r2 * A[0] + r * r2 * (A[1] + r * A[2] + r2 * (A[3] + r * A[4])) + hi;
  return y;
}

#undef WANT_ROUNDING
#undef HI
#undef LO
#undef T
#undef T2
#undef B
#undef A
#undef Ln2hi
#undef Ln2lo
#undef N
#undef OFF
#undef LOG_TABLE_BITS

#endif
