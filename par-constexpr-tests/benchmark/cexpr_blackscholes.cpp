#include <array>
#include <algorithm>
#include <iostream>
#include <fstream>
#include <type_traits>
#include <execution>
#include <complex>

#include "cest/cmath.hpp"

namespace blackscholes {
  constexpr int nruns = 16; // need to find a good number for this
  
  template <typename T = double/*fortran real*/> 
  struct OptionData {
      inline constexpr OptionData () {
        OptionType = 1;
      }
      
      inline constexpr OptionData(const T& s, const T& strike, const T& r,
                        const T& v, const T& t, const char& optiontype) 
          : s(s), strike(strike), r(r), v(v), t(t), 
          optiontype(optiontype) {
      }

      inline constexpr OptionData<T> &operator=(const OptionData<T> &rhs) {
        s = rhs.s;
        strike = rhs.strike;
        r = rhs.r;
        v = rhs.v;
        t = rhs.t;
        optiontype = rhs.optiontype;
        return (* this) 
      }
      
      T s, strike, r, v, t;
      char optiontype;
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
      local += kpow[i] * magic[i];

    local = 1.0f - (local * cest::exp(-(0.5f * xinput * xinput)) * 0.3989423f);
    
    if (sgn)
      local = 1.0f - local;

    return local;
  }
  
  // I have no idea what the Sequrono segment of this means, so the 
  // capitlization is arbitrary for now
  template <typename T = double> 
  inline constexpr double BlkSchlSeqEuroNoDiv(const OptionData<T>& dat) {
    char otype = (dat.optiontype == 'P') ? 1 : 0;

    double xd1 = (((dat.r + (dat.v * dat.v * 0.5f)) * dat.t) + 
                    cest::log(dat.s / dat.strike));
    double xden = dat.v * cest::sqrt(dat.t);
    xd1 = xd1 / xden;
    double xd2 = xd1 - xden;
    double nofxd1 = CndF(xd1);
    double nofxd2 =  CndF(xd2);
    double futurevaluex = (dat.strike * cest::exp(-(dat.r * dat.t)));

    if ((otype == 0)) 
      return ((dat.s * nofxd1) - (futurevaluex * nofxd2));
    else
      return (futurevaluex * (1.0f - nofxd2)) - (dat.s * (1.0f - nofxd1));
  }
  
  constexpr auto calc() {
    std::array<double, /*numoptions from file*/> prices{};  // output
    std::array<OptionData, /*numoptions from file*/> dat{}; // input data
  
    for (int i = 0; i < nruns; ++i) {
      prices[i] = BlkSchlSeqEuroNoDiv(dat[i]);
    }

    return prices;
  }
  
} // namespace blackscholes

bool WritePricesToFile(auto buffer, std::string fname) {
  std::ofstream ofs; 
  ofs.open(fname);

  ofs << "count: " << 1 << "\n";

  for (int i = 0; i < buffer.size(); ++i)
    ofs << buffer[i] << "\n";

  ofs.close(); 

  return true;
}


int main() {
 
  // work out how to store data 

  /*
    4 // num options
    
    (((((((((__in >> (__this . s)) >> (__this . strike)) >> (__this . r)) >> (__this . divq)) >> (__this . v)) >> (__this . t)) >> (__this . optiontype)) >> (__this . divs)) >> (__this . dgrefval));
    42.00 40.00 0.1000 0.00 0.20 0.50 C 0.00 4.759423036851750055
    42.00 40.00 0.1000 0.00 0.20 0.50 P 0.00 0.808600016880314021
    100.00 100.00 0.0500 0.00 0.15 1.00 P 0.00 3.714602051381290071
    100.00 100.00 0.0500 0.00 0.15 1.00 C 0.00 8.591659601309890704
  */
  /*constexpr*/ auto data = blackscholes::calc();

  WritePricesToFile(data, "blackscholes_out.dat")

  return 0;
}
