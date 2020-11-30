#ifndef __CEXPR_E_SQRT_
#define __CEXPR_E_SQRT_

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

#include "cexpr_e_sqrtf.hpp"
#include "cexpr_sqrt_tbl.hpp"

#include <iostream>

#include <endian.h>
#include <type_traits>

// taken from glibc's endian.h file, the file has no copyright notice, so I'm
// assuming it falls under the GNU Lesser General Public License
# if __FLOAT_WORD_ORDER == __BIG_ENDIAN
#  define BIG_ENDI 1
#  undef LITTLE_ENDI
#  define HIGH_HALF 0
#  define  LOW_HALF 1
# else
#  if __FLOAT_WORD_ORDER == __LITTLE_ENDIAN
#   undef BIG_ENDI
#   define LITTLE_ENDI 1
#   define HIGH_HALF 1
#   define  LOW_HALF 0
#  endif
# endif

// default implementation from glibc include/fenv.h, if you want a different 
// rounding version you can just swap the return value, all it does is affect 
// the switch statement. However, the if statement relies on some defines that
// come from libc I believe that are set dependent on your architectures 
// capabilities
// 
// these vary by architecture so this is borrowing some numbering from powerpc
// right now, but it may as well just be arbitrary numbers
#define FE_TONEAREST  0
#define FE_TOWARDZERO 1
#define FE_UPWARD     2
#define FE_DOWNWARD   3

constexpr int __cexpr_fegetround (void) {
  return FE_TONEAREST;
}

// Borrowed from glibc generic/math-barriers.h
/* math_force_eval ensures that its floating-point argument is evaluated for 
   its side effects even if its value is apparently unused, and that the
   evaluation of its argument is not moved after the call. Both these
   macros are used to ensure the correct ordering of floating-point
   expression evaluations with respect to accesses to the floating-point 
   environment.
*/
#define math_force_eval(x)						\
  ({ __typeof (x) __x = (x); __asm __volatile__ ("" : : "m" (__x)); })


// taken from glibc sysdeps/ieee754/dbl-64/dla.h
/* CN = 1+2**27 = '41a0000002000000' IEEE double format.  Use it to split a
   double for better accuracy.  */
#define  CN   134217729.0

// taken from glibc sysdeps/ieee754/dbl-64/dla.h
// this is the default not fast math variation as the other requires 
// a constexpr __builtin_fma
# define  EMULV(x, y, z, zz)          \
    ({  __typeof__ (x) __p, hx, tx, hy, ty;          \
        __p = CN * (x);  hx = ((x) - __p) + __p;  tx = (x) - hx; \
        __p = CN * (y);  hy = ((y) - __p) + __p;  ty = (y) - hy; \
        z = (x) * (y); zz = (((hx * hy - z) + hx * ty) + tx * hy) + tx * ty; \
    })

// taken from glibc sysdeps/ieee754/dbl-64/mydefs.h
#define max(x, y)  (((y) > (x)) ? (y) : (x))
#define min(x, y)  (((y) < (x)) ? (y) : (x))

/*********************************************************************/
/* An ultimate sqrt routine. Given an IEEE double machine number x   */
/* it computes the correctly rounded (to nearest) value of square    */
/* root of x.                                                        */
/*********************************************************************/

namespace {
  static constexpr double
    rt0 = 9.99999999859990725855365213134618E-01,
    rt1 = 4.99999999495955425917856814202739E-01,
    rt2 = 3.75017500867345182581453026130850E-01,
    rt3 = 3.12523626554518656309172508769531E-01;
  static constexpr double big = 134217728.0;
  
//  typedef union { int i[2]; double x; } __sqrt_float_union;
}

// Modifications:
// 1) I've walled some calls to a macro math_force_eval, which applies the 
// volatile qualifier and uses inline assembly via __asm (invalid in constexpr)
// to make sure the compiler doesn't reorder operations in a way it shouldn't.
// I don't believe this will be a problem at compile time... but at runtime at
// higher optimization levels it might be.
// 2) As union member swapping in a constexpr context is currently unsupported 
// by Clang I've had to do some bitwise operations to try and yield the same 
// result
// 3) The fe getround function is the default fallback implementation for the 
// moment, not too sure if there's a better way to do it at compile time just 
// yet as the actual implementation can variy per architecture from what I can 
// tell
// 4) I removed some functions relating to floating point exceptions something 
// that we're not too interested in at compile time
constexpr double cexpr_sqrt(double x) {
  double y = 0, t = 0, del = 0, res = 0, res1 = 0, hy = 0, z = 0, zz = 0, s = 0;
  int k = 0;

  // a very messy attempt at replacing the usage of a union to get the high and 
  // low bits of our data. It replaces the below segment and it does not factor
  // in the endianess of your machine it'll only take into consideration little
  // endian machines at the moment (least to most significant bits).
  //
  // __sqrt_float_union a = { { 0, 0 } }, c = { { 0, 0 } };
  //  a.x = x;
  //  k = a.i[HIGH_HALF];
  //  a.i[HIGH_HALF] = (k & 0x001fffff) | 0x3fe00000;
  //  t = inroot[(k & 0x001fffff) >> 14];
  //  s = a.x;

  int64_t number = cexpr_bit_cast<int64_t>(x);
  int high_low[2] = {0,0};
  high_low[0] = number & 0xFFFFFFFFF; // low word
  high_low[1] = number >> 32; // high word
  k = high_low[1];
  high_low[1] = (k & 0x001fffff) | 0x3fe00000;
  t = cexpr_inroot[(k & 0x001fffff) >> 14];
  s = cexpr_bit_cast<double>(high_low);

  /*----------------- 2^-1022  <= | x |< 2^1024  -----------------*/
  if (k > 0x000fffff && k < 0x7ff00000) {
      int rm = __cexpr_fegetround();
      double ret;
      y = 1.0 - t * (t * s);
      t = t * (rt0 + y * (rt1 + y * (rt2 + y * rt3)));
      
      // appears to be no lowbits
      int chigh_low[2];
      chigh_low[0] = 0;
      chigh_low[1] = 0x20000000 + ((k & 0x7fe00000) >> 1);
      double cx = cexpr_bit_cast<double>(chigh_low);

      y = t * s;
      hy = (y + big) - big;
      del = 0.5 * t * ((s - hy * hy) - (y - hy) * (y + hy));
      res = y + del;
      if (res == (res + 1.002 * ((y - res) + del)))
        ret = res * cx;
      else {
        res1 = res + 1.5 * ((y - res) + del);
        EMULV (res, res1, z, zz); /* (z+zz)=res*res1 */
        res = ((((z - s) + zz) < 0) ? max (res, res1) :
        min (res, res1));
        ret = res * cx;
      }
      
      // left in and walled off so it behaves as it should at runtime
      if (!std::is_constant_evaluated())
        math_force_eval(ret);

      double dret = x / ret;
      if (dret != ret) {
        double force_inexact = 1.0 / 3.0;
        
      // left in and walled off so it behaves as it should at runtime
      if (!std::is_constant_evaluated())
        math_force_eval(ret);

        /* The square root is inexact, ret is the round-to-nearest
           value which may need adjusting for other rounding
           modes.  */
        switch (rm) {
#ifdef FE_UPWARD
          case FE_UPWARD:
            if (dret > ret)
              ret = (res + 0x1p-1022) * cx;
            break;
#endif

#ifdef FE_DOWNWARD
          case FE_DOWNWARD:
#endif
#ifdef FE_TOWARDZERO
          case FE_TOWARDZERO:
#endif
#if defined FE_DOWNWARD || defined FE_TOWARDZERO
           if (dret < ret)
             ret = (res - 0x1p-1022) * cx;
          break;
#endif
          default:
            break;
        }
      }
      /* Otherwise (x / ret == ret), either the square root was exact or
         the division was inexact.  */
      return ret;
    } else {

      if ((k & 0x7ff00000) == 0x7ff00000)
        return x * x + x; /* sqrt(NaN)=NaN, sqrt(+inf)=+inf, sqrt(-inf)=sNaN */

      if (x == 0)
        return x;       /* sqrt(+0)=+0, sqrt(-0)=-0 */

      if (k < 0) // this guarantees a divide by 0 which is a compile time error
        return (x - x) / (x - x); /* sqrt(-ve)=sNaN */
            
//      the result of cexpr_sqrtf appears to be incorrect, it returns inf
//      std::cout << "cexpr_sqrtf? " << cexpr_sqrtf(x * 0x1p512) << "\n";
      
      return 0x1p-256 * cexpr_sqrt(x * 0x1p512);
    }

  return 1.0;
}

#undef min
#undef max
#undef math_force_eval
#undef HIGH_HALF
#undef LOW_HALF
#undef LITTLE_ENDI
#undef BIG_ENDI

#endif
