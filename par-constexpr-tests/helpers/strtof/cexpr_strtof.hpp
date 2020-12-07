/*
 * strtof.c --
 *
 *  Source code for the "strtof" library procedure.
 *
 * Copyright (c) 1988-1993 The Regents of the University of California.
 * Copyright (c) 1994 Sun Microsystems, Inc.
 *
 * See the file "license.terms" for information on usage and redistribution
 * of this file, and for a DISCLAIMER OF ALL WARRANTIES.
 *
 * SCCS: @(#) strtof.c 1.9 96/12/13 15:02:46
 *
 */

// Note: This is not from glibc, it's a rather old OpenBSD(?) implementation 
// from as far back as 2003. The glibc version is a lot more complicated and 
// this implementation does the trick for now.

#include <ctype.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdlib.h>

const int maxExponent = 38; /* Largest possible base 10 exponent.  Any
				 * exponent larger than this will already
				 * produce underflow or overflow, so there's
				 * no need to worry about additional digits.
				 */

constexpr float _strtof_powersOf10_[] = { 
         // Table giving binary powers of 10.  Entry
	10.0f, // is 10^2^i.  Used to convert decimal
	100.0f, // exponents into floating-point numbers.
	1.0e4f, 1.0e8f, 1.0e16f, 1.0e32f};

constexpr bool cexpr_isspace(char c) {
  return c == ' ';
}

constexpr bool cexpr_isdigit(char c) {
  return c == '0' || c == '1' || c == '2' || c == '3' || c == '4' || c == '5'
      || c == '6' || c == '7' || c == '8' || c == '9';
}

/*
 *----------------------------------------------------------------------
 *
 * strtof --
 *
 *	This procedure converts a floating-point number from an ASCII
 *	decimal representation to internal double-precision format.
 *
 * Results:
 *	The return value is the double-precision floating-point
 *	representation of the characters in string.  If endPtr isn't
 *	NULL, then *endPtr is filled in with the address of the
 *	next character after the last one that was part of the
 *	floating-point number.
 *
 * Side effects:
 *	None.
 *
 *----------------------------------------------------------------------
 */

constexpr float cexpr_strtof(const char* string, 
           /* A decimal ASCII floating-point number,
            * optionally preceded by white space.
					  * Must have form "-I.FE-X", where I is the
					  * integer part of the mantissa, F is the
					  * fractional part of the mantissa, and X
					  * is the exponent.  Either of the signs
					  * may be "+", "-", or omitted.  Either I
					  * or F may be omitted, or both.  The decimal
					  * point isn't necessary unless F is present.
					  * The "E" may actually be an "e".  E and X
					  * may both be omitted (but not just one).
					  */
			 char** endPtr /* If non-NULL, store terminating character's
	   * address here. */
			 )
{
	int sign, expSign = false;
	float fraction, dblExp;
	const float* d;
	const char* p;
	int c;
	int exp = 0; /* Exponent read from "EX" field. */
	int fracExp = 0; /* Exponent that derives from the fractional
* part.  Under normal circumstatnces, it is
* the negative of the number of digits in F.
* However, if I is very long, the last digits
* of I get dropped (otherwise a long I with a
* large negative exponent could cause an
* unnecessary overflow on I alone).  In this
* case, fracExp is incremented one for each
* dropped digit. */
	int mantSize; /* Number of digits in mantissa. */
	int decPt; /* Number of mantissa digits BEFORE decimal
* point. */
	const char* pExp; /* Temporarily holds location of exponent
*in string. */

	/*
	 * Strip off leading blanks and check for a sign.
	 */

	p = string;
	while(cexpr_isspace(*p))
	{
		p += 1;
	}
	if(*p == '-')
	{
		sign = true;
		p += 1;
	}
	else
	{
		if(*p == '+')
		{
			p += 1;
		}
		sign = false;
	}

	/*
	 * Count the number of digits in the mantissa (including the decimal
	 * point), and also locate the decimal point.
	 */

	decPt = -1;
	for(mantSize = 0;; mantSize += 1)
	{
		c = *p;
		if(!cexpr_isdigit(c))
		{
			if((c != '.') || (decPt >= 0))
			{
				break;
			}
			decPt = mantSize;
		}
		p += 1;
	}

	/*
	 * Now suck up the digits in the mantissa.  Use two integers to
	 * collect 9 digits each (this is faster than using floating-point).
	 * If the mantissa has more than 18 digits, ignore the extras, since
	 * they can't affect the value anyway.
	 */

	pExp = p;
	p -= mantSize;
	if(decPt < 0)
	{
		decPt = mantSize;
	}
	else
	{
		mantSize -= 1; /* One of the digits was the point. */
	}
	if(mantSize > 18)
	{
		fracExp = decPt - 18;
		mantSize = 18;
	}
	else
	{
		fracExp = decPt - mantSize;
	}
	if(mantSize == 0)
	{
		fraction = 0.0;
		p = string;

    if(endPtr != NULL)
      *endPtr = (char*)p;

    if (sign)
      return -fraction;

    return fraction;
	}
	else
	{
		int frac1, frac2;
		frac1 = 0;
		for(; mantSize > 9; mantSize -= 1)
		{
			c = *p;
			p += 1;
			if(c == '.')
			{
				c = *p;
				p += 1;
			}
			frac1 = 10 * frac1 + (c - '0');
		}
		frac2 = 0;
		for(; mantSize > 0; mantSize -= 1)
		{
			c = *p;
			p += 1;
			if(c == '.')
			{
				c = *p;
				p += 1;
			}
			frac2 = 10 * frac2 + (c - '0');
		}
		fraction = (1.0e9f * frac1) + frac2;
	}

	/*
	 * Skim off the exponent.
	 */

	p = pExp;
	if((*p == 'E') || (*p == 'e'))
	{
		p += 1;
		if(*p == '-')
		{
			expSign = true;
			p += 1;
		}
		else
		{
			if(*p == '+')
			{
				p += 1;
			}
			expSign = false;
		}
		while(cexpr_isdigit(*p))
		{
			exp = exp * 10 + (*p - '0');
			p += 1;
		}
	}
	if(expSign)
	{
		exp = fracExp - exp;
	}
	else
	{
		exp = fracExp + exp;
	}

	/*
	 * Generate a floating-point number that represents the exponent.
	 * Do this by processing the exponent one bit at a time to combine
	 * many powers of 2 of 10. Then combine the exponent with the
	 * fraction.
	 */

	if(exp < 0)
	{
		expSign = true;
		exp = -exp;
	}
	else
	{
		expSign = false;
	}

	if(exp > maxExponent)
	{
		exp = maxExponent;
	}
	dblExp = 1.0f;

	for(d = _strtof_powersOf10_; exp != 0; exp >>= 1, d += 1)
	{
		if(exp & 01)
		{
			dblExp *= *d;
		}
	}

	if(expSign)
	{
		fraction /= dblExp;
	}
	else
	{
		fraction *= dblExp;
	}

	if(endPtr != NULL)
	{
		*endPtr = (char*)p;
	}

	if(sign)
	{
		return -fraction;
	}
	return fraction;
}
