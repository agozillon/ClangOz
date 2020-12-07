#include <array>
#include <algorithm>
#include <iostream>
#include <fstream>
#include <cstdio>
#include <type_traits>
#include <execution>
#include <complex>

using namespace __cep::experimental;

#include "../helpers/strtof/cexpr_strtof.hpp"
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

namespace blackscholes {
  constexpr int nruns = 1; // need to find a good number for this
  
  template <typename T = float/*fortran real*/> 
  struct OptionData {
      constexpr OptionData () {
        optiontype = 1;
        error = false;
        price = 0;
      }
      
      constexpr OptionData(const T& s, const T& strike, const T& r,
                        const T& v, const T& t, const char& optiontype) 
          : s(s), strike(strike), r(r), v(v), t(t), optiontype(optiontype) {
      }

      constexpr OptionData<T> &operator=(const OptionData<T> &rhs) {
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

  template <typename T = float>
  constexpr T CndF (const T& input) {
    T xinput;
    T kpow2[5];
    bool sgn;
    
    if (input < 0.0) {
      xinput = -input;
      sgn = true;
    } else {
      xinput = input;
      sgn = false;
    }

    // computing some powers optimally like the original, even if it degrades 
    // reading a bit
    kpow2[0] = (1.0 / (1.0 + (0.2316419 * xinput)));
    for (int i = 0; i < 4; ++i) 
      kpow2[i + 1] = kpow2[i] * kpow2[0];

    // these need to be doubles even if the result / inputs are floats otherwise
    // they lose precision or are at least not the same as if you typed them in
    // as a constant
    const double magic[5] = {0.319381530, -0.356563782, 1.781477937, 
                            -1.821255978, 1.330274429};

    T local = 0;
    for (int i = 0; i < 5; ++i)
      local += kpow2[i] * magic[i];
      
    local = 1.0 - (local * (cexpr_expf(-0.5f * xinput * xinput) 
                    * inv_sqrt_2xPI));

    if (sgn)
      local = 1.0 - local;

    return local;
  }

  template <typename T = float> 
  constexpr T BlkSchlsEqEuroNoDiv(const OptionData<T>& dat) {
    char otype = (dat.optiontype == 'P') ? 1 : 0;

    float xd1 = (((dat.r + (dat.v * dat.v * 0.5)) * dat.t) + 
                    cexpr_logf(dat.s / dat.strike));
    float xden = dat.v * cexpr_sqrtf(dat.t);
    xd1 = xd1 / xden;
    float xd2 = xd1 - xden;

    float nofxd1 = CndF(xd1);
    float nofxd2 =  CndF(xd2);

    float futurevaluex = (dat.strike * cexpr_expf(-(dat.r * dat.t)));

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
    std::array<OptionData<float>, numOfData> data{}; // input data

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
              data[currentData].s = cexpr_strtof(tmp, nullptr);
            break;
          case 1:
              data[currentData].strike = cexpr_strtof(tmp, nullptr);
            break;
          case 2:
              data[currentData].r = cexpr_strtof(tmp, nullptr);
            break;
          case 3: // divq, doesn't seem to be used
            break;
          case 4:
              data[currentData].v = cexpr_strtof(tmp, nullptr);
            break;
          case 5:
              data[currentData].t = cexpr_strtof(tmp, nullptr);
            break;
          case 6:
              data[currentData].optiontype = tmp[0];
            break;
          case 7: // divs, doesn't seem to be used
            break;
          case 8: // dgrefval, reference/golden value for calculated price
              data[currentData].dgrefval = cexpr_strtof(tmp, nullptr);
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
    // version, it's the similar output minus some precision from rounding 
    // errors and order of operations as I refactored the functions. 
    // 
    // Unfortunately we can only get within 1e-4 margin of error the same as 
    // ParSec can manage, 1e-5 is a little too strict
#ifdef CONSTEXPR_PARALLEL
    std::for_each(execution::ce_par, data.begin(), data.end(), 
      [](auto& data) mutable {
        if (cest::fabs(data.dgrefval - data.price) >= 1e-4)
          data.error = true;
    });
#else
    for (int i = 0; i < data.size(); ++i)
      if (cest::fabs(data[i].dgrefval - data[i].price) >= 1e-4)
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
    ofs << std::setprecision(std::numeric_limits<float>::digits10 + 1) 
        << buffer[i].price << "  " << buffer[i].error << "\n";

  ofs.close(); 

  return true;
}

bool WritePricesToFilePrintf(auto buffer, std::string fname) {
    //Write prices to output file
    auto file = fopen(fname.c_str(), "w");

    fprintf(file, "%zu\n", buffer.size());

    for (int i = 0; i < buffer.size(); i++) {
      fprintf(file, "%.18f\n", buffer[i].price);
    }
    
    fclose(file);

    return true;
}

//the problem may be the scuffed way we have to read in input data at compile time
//test it at runtime by replacing all functions with their std:: variants and reading
//in the input at runtime the same as we'd normally do in the parsec benchmark / pauls

//if it's still wrong then there is a problem in the code, if it's correct then we just
//have to live with the fact that our constexpr read in is killing some of the precision
int main() {
  constexpr auto outData = blackscholes::Calc();
  
  for (auto dat : outData) {
    if (dat.error == true)
      std::cout << "error was detected \n";
  }

//  prints with less precision
//  WritePricesToFile(outData, "blackscholes_out.dat");

  WritePricesToFilePrintf(outData, "blackscholes_out.dat");
  return 0;
}
