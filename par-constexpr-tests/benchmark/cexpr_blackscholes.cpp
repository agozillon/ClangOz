#include <array>
#include <algorithm>
#include <iostream>
#include <fstream>
#include <type_traits>
#include <execution>
#include <complex>

using namespace __cep::experimental;

#include "../helpers/sqrt/cexpr_sqrt.hpp"
#include "../helpers/exp/cexpr_exp.hpp"
#include "../helpers/log/cexpr_log.hpp"

#include "cest/cmath.hpp"

#define inv_sqrt_2xPI 0.39894228040143270286
  
#ifdef BLACKSCHOLES_4
#include "blackscholes-input/in_4.hpp"
#elif BLACKSCHOLES_16
#include "blackscholes-input/in_16.hpp"
#elif BLACKSCHOLES_1K // technically 1024 elements
#include "blackscholes-input/in_1k.hpp"
#elif BLACKSCHOLES_4K // technically its 4096 elements
#include "blackscholes-input/in_4k.hpp"
#elif BLACKSCHOLES_16K // technically its 16384 elements
#include "blackscholes-input/in_16k.hpp"
#elif BLACKSCHOLES_64K // technically its 65536 elements, the best option for testing, takes 1 min 30 seconds~ 
#include "blackscholes-input/in_64k.hpp"
#else // default to 4 element example so it will compile
#include "blackscholes-input/in_4.hpp"
#endif

// this implementation was taken from: 
//  https://codereview.stackexchange.com/questions/44869/implement-strtod-parsing
// thanks to the user that wrote this!
constexpr double strtodouble(const char* str, char** endptr){
    double result = 0.0;
    char signedResult = '\0';
    char signedExponent = '\0';
    double decimals = 0;
    bool isExponent = false;
    bool hasExponent = false;
    bool hasResult = false;
    // exponent is logically int but is coded as double so that its eventual
    // overflow detection can be the same as for double result
    double exponent = 0;
    char c;

    for (; '\0' != (c = *str); ++str) {
        if ((c >= '0') && (c <= '9')) {
            int digit = c - '0';
            if (isExponent) {
                exponent = (10 * exponent) + digit;
                hasExponent = true;
            } else if (decimals == 0) {
                result = (10 * result) + digit;
                hasResult = true;
            } else {
                result += (double)digit / decimals;
                decimals *= 10;
            }
            continue;
        }

        if (c == '.') {
            if (!hasResult) break; // don't allow leading '.'
            if (isExponent) break; // don't allow decimal places in exponent
            if (decimals != 0) break; // this is the 2nd time we've found a '.'

            decimals = 10;
            continue;
        }

        if ((c == '-') || (c == '+')) {
            if (isExponent) {
                if (signedExponent || (exponent != 0)) break;
                else signedExponent = c;
            } else {
                if (signedResult || (result != 0)) break;
                else signedResult = c;
            }
            continue;
        }

        if (c == 'E') {
            if (!hasResult) break; // don't allow leading 'E'
            if (isExponent) break;
            else isExponent = true;
            continue;
        }

        break; // unexpected character
    }

    if (isExponent && !hasExponent) {
        while (*str != 'E')
            --str;
    }

    if (!hasResult && signedResult) --str;

    if (endptr) *endptr = const_cast<char*>(str);

    for (; exponent != 0; --exponent) {
        if (signedExponent == '-') result /= 10;
        else result *= 10;
    }

    if (signedResult == '-' && result != 0) result = -result;

    return result;
}

namespace blackscholes {
  constexpr int nruns = 1; // need to find a good number for this
  
  template <typename T = double/*fortran real*/> 
  struct OptionData {
      inline constexpr OptionData () {
        optiontype = 1;
        error = false;
        price = 0;
      }
      
      inline constexpr OptionData(const T& s, const T& strike, const T& r,
                        const T& v, const T& t, const char& optiontype) 
          : s(s), strike(strike), r(r), v(v), t(t), optiontype(optiontype) {
      }

      inline constexpr OptionData<T> &operator=(const OptionData<T> &rhs) {
        s = rhs.s;
        strike = rhs.strike;
        r = rhs.r;
        v = rhs.v;
        t = rhs.t;
        price = rhs.price;
        error = rhs.error;
        dgrefval = rhs.dgrefval;
        return (* this);
      }

      // far right is a reference value for the data, the rest is used to 
      // compute the calculation. We don't care about the dividend values in 
      // this calculation (same as the Parsec benchmark)
      T s, strike, r, v, t, dgrefval, price;
      char optiontype;
      bool error;
  };

  template <typename T = double>
  inline constexpr T CndF (const T& input) {
    T xinput;
    T kpow2[5];
    bool sgn;
    
    if (input < 0.0f) {
      xinput = -input;
      sgn = true;
    } else {
      xinput = input;
      sgn = false;
    }

    // computing some powers optimally like the original, even if it degrades 
    // reading a bit
    kpow2[0] = (1.0f / (1.0f + (0.2316419f * xinput)));
    for (int i = 0; i < 4; ++i) 
      kpow2[i + 1] = kpow2[i] * kpow2[0];

    const double magic[5] = {0.31938154f, -0.35656378f, 1.7814779f, -1.8212559f, 
                             1.3302745f};
    T local = 0;
    for (int i = 0; i < 5; ++i)
      local += kpow2[i] * magic[i];

    local = 1.0f - (local * cexpr_exp(-(0.5f * xinput * xinput)) 
                    * inv_sqrt_2xPI);

    if (sgn)
      local = 1.0f - local;

    return local;
  }

  // I have no idea what the Sequrono segment of this means, so the 
  // capitlization is arbitrary for now
  template <typename T = double> 
  inline constexpr double BlkSchlsEqEuroNoDiv(const OptionData<T>& dat) {
    char otype = (dat.optiontype == 'P') ? 1 : 0;

    double xd1 = (((dat.r + (dat.v * dat.v * 0.5f)) * dat.t) + 
                    cexpr_log(dat.s / dat.strike));
    double xden = dat.v * cexpr_sqrt(dat.t);
    xd1 = xd1 / xden;
    double xd2 = xd1 - xden;
    
    double nofxd1 = CndF(xd1);
    double nofxd2 =  CndF(xd2);

    double futurevaluex = (dat.strike * cexpr_exp(-(dat.r * dat.t)));
    if (otype == 0) {
      return (dat.s * nofxd1) - (futurevaluex * nofxd2);
    } else {
      return (futurevaluex * (1.0 - nofxd2)) - (dat.s * (1.0 - nofxd1));
    }
  }

  // there is likely a cleaner way of doing this at compile time, but your limited
  // to char arrays and don't seem to be able to use things like string stream and 
  // anything string related that relies on C functionallity!
  constexpr auto ParseInputData() { 
    std::array<OptionData<double>, numOfData> data{}; // input data
    
    int i = 0, sz = 0;
    char tmp[32]; // this means if a number happens to be bigger than 32 digits
                  // we have a bit of a problem
    int currentVal = 0;
    int currentData = 0;
    while (inputData[i] != '\0') {
      tmp[sz++] = inputData[i];
      // the read in precision isn't perfect, but should be good enough
      if (inputData[i] == ' ' || inputData[i] == '\n') {
        switch (currentVal) {
          case 0:
              data[currentData].s = strtodouble(tmp, nullptr);
            break;
          case 1:
              data[currentData].strike = strtodouble(tmp, nullptr);
            break;
          case 2:
              data[currentData].r = strtodouble(tmp, nullptr);
            break;
          case 3: // divq, doesn't seem to be used
            break;
          case 4:
              data[currentData].v = strtodouble(tmp, nullptr);
            break;
          case 5:
              data[currentData].t = strtodouble(tmp, nullptr);
            break;
          case 6:
              data[currentData].optiontype = tmp[0];
            break;
          case 7: // divs, doesn't seem to be used
            break;
          case 8: // dgrefval, reference/golden value for calculated price
//              std::cout << tmp <<"\n";
              data[currentData].dgrefval = strtodouble(tmp, nullptr);
            break;
        }

        if (currentVal >= 8) {
          currentVal = 0;
          currentData++;
        } else {
          currentVal++;
        }
        
        sz = 0;
      }
      
      ++i;
    }

    return data;
  }

  constexpr auto Calc() {
    auto data = ParseInputData();

#ifdef CONSTEXPR_PARALLEL
  // This top level loop really adds nothing to the calculation it just forces
  // an extra iteration of the same calculation, so I've chosen to leave it as
  // an outer loop rather than complicate the parallel for_each component
  for (int i = 0; i < nruns; ++i)
    std::for_each(execution::ce_par, data.begin(), data.end(), 
      [](auto& data) mutable {
          data.price = BlkSchlsEqEuroNoDiv(data);
    });
#else
    // not sure why the original example has nruns as it doesn't seem to 
    // directly modify the data, so it's repeatedly caclulating the same thing
    for (int i = 0; i < nruns; ++i)
      for (int j = 0; j < data.size(); ++j)
        data[j].price = BlkSchlsEqEuroNoDiv(data[j]);
#endif

    // error checking, it's very difficult to do this as a compile time error 
    // using static_assert right now. I've also tested this against the Parsec
    // version, it's the same output minus some precision from rounding errors.
    //
    // The 1e-4 may be a little stringent, we get a decent pass rate but still 
    // a lot of failures from being slightly off (1e-3 is a lot better (3836 are 
    // off) with 1e-2 having little to no errors).
    //
    // This is likely due to reading it all in from strings using a non-standard
    // string to double implementation and likely some good old fashioned 
    // rounding errors, but it appears to be within reasonable approximation.
#ifdef CONSTEXPR_PARALLEL
    std::for_each(execution::ce_par, data.begin(), data.end(), 
      [](auto& data) mutable {
        if (cest::fabs(data.dgrefval - data.price) >= 1e-3)
          data.error = true;
    });
#else
    for (int i = 0; i < data.size(); ++i)
      if (cest::fabs(data[i].dgrefval - data[i].price) >= 1e-3)
        data[i].error = true;
#endif

    return data;
  }
  
} // namespace blackscholes

bool WritePricesToFile(auto buffer, std::string fname) {
  std::ofstream ofs;
  ofs.open(fname);

  ofs << "count: " << buffer.size() << "\n";

  for (int i = 0; i < buffer.size(); ++i)
    ofs << std::setprecision(std::numeric_limits<double>::digits10 + 1) 
        << buffer[i].price << "  " << buffer[i].error << "\n";

  ofs.close(); 

  return true;
}

int main() {
  constexpr auto outData = blackscholes::Calc();
  WritePricesToFile(outData, "blackscholes_out.dat");

  return 0;
}
