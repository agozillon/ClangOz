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
#ifndef __CEXPR_EXP_
#define __CEXPR_EXP_

// This file contains all the code segments from glibc required to make 
// the double variation of the IEEE754 e_exp.c file from glibc constexpr!
//
// It's worth noting it has a chunk of changes, largelly removal of things that
// do not work in constexpr, like certain paths for builtins that will never be 
// used

#include "../cexpr_math_helpers.hpp"
#include "cexpr_e_exp_data.hpp"

#define EXP_TABLE_BITS 7
#define EXP_POLY_ORDER 5
#define EXP2_POLY_ORDER 5
#define N (1 << EXP_TABLE_BITS)

#define InvLn2N __exp_data.invln2N
#define NegLn2hiN __exp_data.negln2hiN
#define NegLn2loN __exp_data.negln2loN
#define Shift __exp_data.shift
#define T __exp_data.tab
#define C2 __exp_data.poly[5 - EXP_POLY_ORDER]
#define C3 __exp_data.poly[6 - EXP_POLY_ORDER]
#define C4 __exp_data.poly[7 - EXP_POLY_ORDER]
#define C5 __exp_data.poly[8 - EXP_POLY_ORDER]

#define WANT_ROUNDING 1

// unfortunately this contains assembly, the code can be found in: 
//  glibc/include/math-narrow-eval.h 
//
// it's likely the assembly can be recreated as regular C++ by someone with more
// knowledge of assembly than i do (i.e. none), the builtins shouldn't be a 
// problem as I believe they are already constexpr in Clang.
//
// For now I will use the default opt out define that exists.
# define cexpr_math_narrow_eval(x) (x)

// both from glibc: generic/math-barriers.h
#define math_opt_barrier(x)					\
  ({ __typeof (x) __x = (x); __asm ("" : "+m" (__x)); __x; })
#define math_force_eval(x)          \
  ({ __typeof (x) __x = (x); __asm __volatile__ ("" : : "m" (__x)); })
  
namespace {
  /* Handle cases that may overflow or underflow when computing the result that
     is scale*(1+TMP) without intermediate rounding.  The bit representation of
     scale is in SBITS, however it has a computed exponent that may have
     overflown into the sign bit so that needs to be adjusted before using it as
     a double.  (int32_t)KI is the k used in the argument reduction and exponent
     adjustment of scale, positive k here means the result may overflow and
     negative k means the result may underflow.  */
  static constexpr double specialcase(double_t tmp, uint64_t sbits, uint64_t ki)
  {
    double_t scale = 0, y = 0;

    if ((ki & 0x80000000) == 0)
      {
        /* k > 0, the exponent of scale might have overflowed by <= 460.  */
        sbits -= 1009ull << 52;
        scale = asdouble (sbits);
        return 0x1p1009 * (scale + scale * tmp);
      }
    /* k < 0, need special care in the subnormal range.  */
    sbits += 1022ull << 52;
    scale = asdouble (sbits);
    y = scale + scale * tmp;
    if (y < 1.0)
      {
        /* Round y to the right precision before scaling it into the subnormal
	   range to avoid double rounding that can cause 0.5+E/2 ulp error where
	   E is the worst-case ulp error outside the subnormal range.  So this
	   is only useful if the goal is better than 1 ulp worst-case error.  */
        double_t hi, lo;
        lo = scale - y + scale * tmp;
        hi = 1.0 + y;
        lo = 1.0 - hi + y + lo;
        y = cexpr_math_narrow_eval (hi + lo) - 1.0;
        /* Avoid -0.0 with downward rounding.  */
        if (WANT_ROUNDING && y == 0.0)
          y = 0.0;
          
        /* The underflow exception needs to be signaled explicitly.  */
        // looks like this will have no affect on the result at compile time
        if (!std::is_constant_evaluated())
          math_force_eval (math_opt_barrier (0x1p-1022) * 0x1p-1022);
      }
    return 0x1p-1022 * y;
  }
}


constexpr double cexpr_exp(double x) {
  uint32_t abstop = 0;
  uint64_t ki = 0, idx  = 0, top  = 0, sbits = 0;
  /* double_t for better performance on targets with FLT_EVAL_METHOD==2.  */
  double_t kd  = 0, z  = 0, r  = 0, r2  = 0, scale = 0, tail = 0, tmp = 0;

  abstop = top12 (x) & 0x7ff;
  // __glibc_unlikely appears to just be a __builtin_expect, which apparently 
  // works in constexpr! And is provided by cdefs so appears to be in scope.
  if (__glibc_unlikely (abstop - top12 (0x1p-54)
			>= top12 (512.0) - top12 (0x1p-54)))
    {
      if (abstop - top12 (0x1p-54) >= 0x80000000)
	/* Avoid spurious underflow for tiny x.  */
	/* Note: 0 is common input.  */
	return WANT_ROUNDING ? 1.0 + x : 1.0;
      if (abstop >= top12 (1024.0))
	{
	  if (asuint64 (x) == asuint64 (-INFINITY))
	    return 0.0;
	  if (abstop >= top12 (INFINITY))
	    return 1.0 + x;
	  if (asuint64 (x) >> 63)
	    return 0; // __math_uflow (0); // errcodes that use assembly, defaults to 0
	  else
	    return 0; // __math_oflow (0);
	}
      /* Large x is special cased below.  */
      abstop = 0;
    }

  /* exp(x) = 2^(k/N) * exp(r), with exp(r) in [2^(-1/2N),2^(1/2N)].  */
  /* x = ln2/N*k + r, with int k and r in [-ln2/2N, ln2/2N].  */
  z = InvLn2N * x;

  /* z - kd is in [-1, 1] in non-nearest rounding modes.  */
  
  // NOTE: this may become a problem as this defaults to 0
  kd = cexpr_math_narrow_eval (z + Shift);
  ki = asuint64 (kd);
  kd -= Shift;

  r = x + kd * NegLn2hiN + kd * NegLn2loN;
  /* 2^(k/N) ~= scale * (1 + tail).  */
  idx = 2 * (ki % N);
  top = ki << (52 - EXP_TABLE_BITS);
  tail = asdouble (T[idx]);
  /* This is only a valid scale when -1023*N < k < 1024*N.  */
  sbits = T[idx + 1] + top;
  /* exp(x) = 2^(k/N) * exp(r) ~= scale + scale * (tail + exp(r) - 1).  */
  /* Evaluation is optimized assuming superscalar pipelined execution.  */
  r2 = r * r;
  /* Without fma the worst case error is 0.25/N ulp larger.  */
  /* Worst case error is less than 0.5+1.11/N+(abs poly error * 2^53) ulp.  */
  tmp = tail + r + r2 * (C2 + r * C3) + r2 * r2 * (C4 + r * C5);
  if (__glibc_unlikely (abstop == 0))
    return specialcase (tmp, sbits, ki);
  scale = asdouble (sbits);
  /* Note: tmp == 0 or |tmp| > 2^-65 and scale > 2^-739, so there
     is no spurious underflow here even without fma.  */
  return scale + scale * tmp;
}

#undef N
#undef InvLn2N
#undef NegLn2hiN
#undef NegLn2loN 
#undef Shift
#undef T
#undef C2
#undef C3
#undef C4
#undef C5 

#undef EXP_TABLE_BITS
#undef EXP_POLY_ORDER
#undef EXP2_POLY_ORDER

#endif
