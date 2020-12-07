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
#ifndef __CEXPR_EXPF_
#define __CEXPR_EXPF_

// This file contains all the code segments from glibc required to make 
// the float variation of the IEEE754 e_expf.c file from glibc constexpr!
//
// It's worth noting it has a chunk of changes, largelly removal of things that
// do not work in constexpr, like certain paths for builtins that will never be 
// used

#include "../cexpr_math_helpers.hpp"
#include "cexpr_e_expf_data.hpp"

// unfortunately this contains assembly, the code can be found in: 
//  glibc/include/math-narrow-eval.h 
//
// it's likely the assembly can be recreated as regular C++ by someone with more
// knowledge of assembly than i do (i.e. none), the builtins shouldn't be a 
// problem as I believe they are already constexpr in Clang.
//
// For now I will use the default opt out define that exists.
#define cexpr_math_narrow_eval(x) (x)

#define EXP2F_TABLE_BITS 5
#define EXP2F_POLY_ORDER 3
#define N (1 << EXP2F_TABLE_BITS)
#define InvLn2N __exp2f_data.invln2_scaled
#define T __exp2f_data.tab
#define C __exp2f_data.poly_scaled
#define SHIFT __exp2f_data.shift

constexpr float cexpr_expf(float x)
{
  uint32_t abstop = 0;
  uint64_t ki = 0, t = 0;
  /* double_t for better performance on targets with FLT_EVAL_METHOD==2.  */
  double_t kd = 0, xd = 0, z = 0, r = 0, r2 = 0, y = 0, s = 0;

  xd = (double_t) x;
  abstop = top12(x) & 0x7ff;
  if (__glibc_unlikely (abstop >= top12 (88.0f)))
  {
      /* |x| >= 88 or x is nan.  */
      if (asuint (x) == asuint (-INFINITY))
        return 0.0f;
      if (abstop >= top12 (INFINITY))
        return x + x;
      if (x > 0x1.62e42ep6f) /* x > log(0x1p128) ~= 88.72 */
        return 0; // __math_oflowf (0); // errcodes that use assembly, 
                                        // defaults to 0
      if (x < -0x1.9fe368p6f) /* x < log(0x1p-150) ~= -103.97 */
        return 0; // __math_uflowf (0); // errcodes that use assembly, 
                                        // defaults to 0
#if WANT_ERRNO_UFLOW
      if (x < -0x1.9d1d9ep6f) /* x < log(0x1p-149) ~= -103.28 */
        return 0; // __math_may_uflowf (0); // errcodes that use assembly, 
                                            // defaults to 0
#endif
  }

  /* x*N/Ln2 = k + r with r in [-1/2, 1/2] and int k.  */
  z = InvLn2N * xd;

  /* Round and convert z to int, the result is in [-150*N, 128*N] and
     ideally ties-to-even rule is used, otherwise the magnitude of r
     can be bigger which gives larger approximation error.  */
  kd = cexpr_math_narrow_eval ((double) (z + SHIFT)); /* Needs to be double.  */
  ki = asuint64 (kd);
  kd -= SHIFT;
  r = z - kd;

  /* exp(x) = 2^(k/N) * 2^(r/N) ~= s * (C0*r^3 + C1*r^2 + C2*r + 1) */
  t = T[ki % N];
  t += ki << (52 - EXP2F_TABLE_BITS);
  s = asdouble (t);
  z = C[0] * r + C[1];
  r2 = r * r;
  y = C[2] * r + 1;
  y = z * r2 + y;
  y = y * s;
  return static_cast<float>(y);
}


#undef cexpr_math_narrow_eval
#undef EXP2F_TABLE_BITS
#undef EXP2F_POLY_ORDER
#undef N
#undef InvLn2N
#undef T
#undef C
#undef SHIFT

#endif
