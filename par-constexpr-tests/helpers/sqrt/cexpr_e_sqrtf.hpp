#ifndef __CEXPR_E_SQRTF_
#define __CEXPR_E_SQRTF_

/*
 * ====================================================
 * Copyright (C) 1993 by Sun Microsystems, Inc. All rights reserved.
 *
 * Developed at SunPro, a Sun Microsystems, Inc. business.
 * Permission to use, copy, modify, and distribute this
 * software is freely granted, provided that this notice
 * is preserved.
 * ====================================================
 */
 
 #include <cstdint>
 #include <bitset>
 #include <math.h>
 

#include <iostream>

/*
 * Conversion to float by Ian Lance Taylor, Cygnus Support, ian@cygnus.com.
 * Constexper'd (minor effort) by Andrew Gozillon
*/
constexpr float cexpr_sqrtf(float x) {
  /* Use generic implementation.  */
  float z = 0;
  int32_t sign = (int)0x80000000;
  int32_t ix = 0, s = 0, q = 0, m = 0, t = 0, i = 0;
  uint32_t r = 0;

  // this replaces the use of union member swapping to get a floats bits
  ix = cexpr_bit_cast<int32_t>(x);

    /* take care of Inf and NaN */
  if((ix&0x7f800000)==0x7f800000) {
      return x*x+x;		/* sqrt(NaN)=NaN, sqrt(+inf)=+inf
           sqrt(-inf)=sNaN */
  }
    /* take care of zero */
  if(ix<=0) {
      if((ix&(~sign))==0) return x;/* sqrt(+-0) = +-0 */
      else if(ix<0)
    return (x-x)/(x-x);		/* sqrt(-ve) = sNaN */
  }
    /* normalize x */
  m = (ix>>23);
  if(m==0) {      /* subnormal x */
      for(i=0;(ix&0x00800000)==0;i++) ix<<=1;
      m -= i-1;
  }
  m -= 127; /* unbias exponent */
  ix = (ix&0x007fffff)|0x00800000;
  if(m&1) /* odd m, double x to make it even */
      ix += ix;
  m >>= 1;  /* m = [m/2] */

    /* generate sqrt(x) bit by bit */
  ix += ix;
  q = s = 0;    /* q = sqrt(x) */
  r = 0x01000000;   /* r = moving bit from right to left */

  while(r!=0) {
      t = s+r;
      if(t<=ix) {
    s    = t+r;
    ix  -= t;
    q   += r;
      }
      ix += ix;
      r>>=1;
  }

    /* use floating add to find out rounding direction */
  if(ix!=0) {
      z = 0x1p0 - 0x1.4484cp-100; /* trigger inexact flag.  */
      if (z >= 0x1p0) {
    z = 0x1p0 + 0x1.4484cp-100;
    if (z > 0x1p0)
        q += 2;
    else
        q += (q&1);
      }
  }
  ix = (q>>1)+0x3f000000;
  ix += (m <<23);

  z = cexpr_bit_cast<float>(ix);

  return z;
}

#endif
