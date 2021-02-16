#include <array>
#include <algorithm>
#include <numeric>
#include <iostream>
#include <fstream>
#include <type_traits>
#include <execution>
#include <complex>

using namespace __cep::experimental;

#include "cest/vector.hpp"
#include "cest/cmath.hpp"

#include "../helpers/sqrt/cexpr_sqrt.hpp"
#include "../helpers/exp/cexpr_exp.hpp"
#include "../helpers/log/cexpr_log.hpp"

namespace swaptions {

// 102400, was the default but its a bit too high for the number of steps
#ifdef NTRIALS_2000
  constexpr int num_trials = 2000;
#elif NTRIALS_4000
  constexpr int num_trials = 4000;
#elif NTRIALS_6000
  constexpr int num_trials = 6000;
#elif NTRIALS_8000
  constexpr int num_trials = 8000;
#elif NTRIALS_10000
  constexpr int num_trials = 10000;
#else
  constexpr int num_trials = 2000;
#endif

/* 
   The original swaptions has a caveat that this 
   has to be the same number as there are cores
   presumably as it's the main parallelization 
   point, for us it cannot go below the numbers 
   of cores and ideally should be a multiple of
   the core count
*/
#ifdef NSWAPTIONS_2
  constexpr int nswaptions = 2;
#elif NSWAPTIONS_4
  constexpr int nswaptions = 4;
#elif NSWAPTIONS_6
  constexpr int nswaptions = 6;
#elif NSWAPTIONS_8
  constexpr int nswaptions = 8;
#elif NSWAPTIONS_10
  constexpr int nswaptions = 10;
#else
  constexpr int nswaptions = 4;
#endif

  constexpr int ki = 4;
  constexpr int m_in = 11;
  constexpr int m_ifactors = 3;
  constexpr int block_size = 16;
  constexpr double m_dyears = 5.5f;

  struct parm {
    constexpr inline parm() {}

    double dstrike;
    double dcompounding;
    double dmaturity;
    double dtenor;
    double dpaymentinterval;
    double dyears;

    std::array<double, m_in - 1> pdyield;
    std::array<std::array<double, m_in - 1>, m_ifactors> ppdfactors;
  };

  struct price {
    constexpr inline price() {}

    double dsimswaptionmeanprice;
    double dsimswaptionstderror;
  };

  constexpr void HJM_Yield_To_Forward(auto &pdforward, const auto &pdyield) {
    pdforward[0] = pdyield[0];
    for (int i = 1; i < pdyield.size(); ++i) {
      pdforward[i] = (i + 1) * pdyield[i] - i * pdyield[i - 1];
    }
  }
  
  constexpr void HJM_Drifts(auto &pdtotaldrift, const double &dyears, 
                            const auto &ppdfactors) {
    std::array<std::array<double, m_in - 1>, m_ifactors> ppddrifts;
    double ddelt = (double)(dyears / m_in);
    double dsumvol = 0;
    
    for (int i = 0; i < ppddrifts.size(); ++i)
      ppddrifts[i][0] = 0.5 * ddelt * ppdfactors[i][0] * ppdfactors[i][0];

   int test = 0;
    for (int i = 0; i < ppddrifts.size(); ++i)
      for (int j = 1; j < ppddrifts[i].size(); ++j) {
        ppddrifts[i][j] = 0;
        for(int l = 0; l < j; ++l)
          ppddrifts[i][j] -= ppddrifts[i][l];

        dsumvol = 0;
        for (int l = 0; l <= j; ++l)
          dsumvol += ppdfactors[i][l];
        
        ppddrifts[i][j] += 0.5* ddelt * dsumvol * dsumvol;
      }

    for(int i = 0; i < pdtotaldrift.size(); ++i) {
      pdtotaldrift[i] = 0;
      for(int j = 0; j < ppddrifts.size(); ++j)
        pdtotaldrift[i] += ppddrifts[j][i];
    }
  }

  constexpr double RanUnif(long &s) {
    long ix = s;
    long k1 = ix / 127773L;
    ix = 16807L * (ix - k1 * 127773L) - k1 * 2836L;
    if (ix < 0) 
      ix = ix + 2147483647L;
    s = ix;
    return (ix * 4.656612875e-10);
  }

  constexpr static double a[4] = { 2.50662823884, -18.61500062529, 
                                   41.39119773534, -25.44106049637 };
  constexpr static double b[4] = { -8.47351093090, 23.08336743743, 
                                   -21.06224101826, 3.13082909833 };
  constexpr static double c[9] = { 0.3374754822726147, 0.9761690190917186, 
                         0.1607979714918209, 0.0276438810333863,
                         0.0038405729373609, 0.0003951896511919,
                         0.0000321767881768, 0.0000002888167364,
                         0.0000003960315187 };

  constexpr double CumNormalInv(double u) {
    double r, x = u - 0.5;
    if (cest::fabs(x) < 0.42) { 
      r = x * x;
      return x * ((( a[3]*r + a[2]) * r + a[1]) * r + a[0]) /
            ((((b[3] * r+ b[2]) * r + b[1]) * r + b[0]) * r + 1.0);
    }

    if (x > 0.0) 
      r = 1.0 - u;
    else 
      r = u;

    r = cexpr_log(-cexpr_log(r));
    r = c[0] + r * (c[1] + r * 
         (c[2] + r * (c[3] + r * 
         (c[4] + r * (c[5] + r * (c[6] + r * (c[7] + r*c[8])))))));

    if (x < 0.0) 
      r = -r;

    return r;
  }

  constexpr void SerialB(auto& pdz, auto& randz) {
    for(int l = 0; l < pdz.size(); ++l)
      for(int b = 0; b < block_size; ++b)
        for (int j = 1; j < m_in - 1; ++j)
          pdz[l][block_size * j + b] = CumNormalInv(randz[l][block_size * j + b]);
  }

  constexpr void HJM_SimPath_Forward_Blocking(auto &ppdhjmpath/*2d array*/,
                                              const double &dyears,
                                              const auto &pdforward/*array*/,
                                              const auto &pdtotaldrift/*array*/,
                                              const auto &ppdfactors/*2d array*/,
                                              long &lrndseed) {
    std::array<std::array<double, m_in * block_size>, m_ifactors> pdz{};
    std::array<std::array<double, m_in * block_size>, m_ifactors> randz{};
    
    double dtotalshock = 0;
    double ddelt = dyears / m_in;
    double sqrt_ddelt = cexpr_sqrt(ddelt);

    // changed this segment so it gives appropriate results, the original had 
    // some slightly weird index generation for the size of the array it created
    // which means it indexes off the side by 1. which is fine for their 
    // dynamically sized special vector, but is no bueno for the std::array.
    int index = 0;
    for (int i = 0; i < ppdhjmpath[0].size(); ++i) {
      if (i > 0 && i % block_size == 0)
        ++index;
      ppdhjmpath[0][i] = pdforward[index];
    }

    for(int i = 1; i < ppdhjmpath.size(); ++i)
      for (int j = 0; j < ppdhjmpath[i].size(); ++j)
        ppdhjmpath[i][j] = 0;

    // same problem as the loop with ppdhjmpath, the offset calculation is 
    // incorrect for the size so it goes off the side... the fix this time is to
    // just resize randz and ignore the final two values, the alternative would 
    // be to have an if to check when we're over indexing, not assign but still
    // call RanUnif, so we continue to maintain the appropriate seed value.
    for(int b = 0; b < block_size; ++b)
      for (int j = 1; j < m_in; ++j)
        for (int l = 0; l < m_ifactors; ++l) {
          randz[l][block_size * j + b] = RanUnif(lrndseed);
        }

    /* apparently 18% of the total executition time */
    SerialB(pdz, randz);

    for(int b = 0; b < block_size; ++b)
      for (int j = 1; j < (m_in - 1); ++j)
        for (int l = 0; l < (m_in - 1) - j; ++l) {
          dtotalshock = 0;
          for (int i = 0; i < m_ifactors; ++i)
            dtotalshock += ppdfactors[i][l] * pdz[i][block_size * j + b];
          
          ppdhjmpath[j][block_size * l + b] = 
            ppdhjmpath[j - 1][block_size * (l + 1) + b] + 
            pdtotaldrift[l] * ddelt + sqrt_ddelt * dtotalshock;
        }
  }

  constexpr void Discount_Factors_Blocking(auto &pddiscountfactors /*array*/,
                                           const int in, 
                                           const double &dyears,
                                           const auto &pdratepath /*array*/) {
    cest::vector<double> pdexpres;
    pdexpres.resize((in - 1)*block_size);
    
    double ddelt = (double) (dyears/in);

    for (int i = 0; i < pdexpres.size(); ++i)
      pdexpres[i] = -pdratepath[i] * ddelt;
    for (int i = 0; i < pdexpres.size(); ++i)
      pdexpres[i] = cexpr_exp(pdexpres[i]);

    for (int i = 0; i < pddiscountfactors.size(); ++i)
      pddiscountfactors[i] = 1.0;

    for (int i = 1; i < in - 1; ++i)
      for (int b = 0; b < block_size; b++)
        for (int j = 0; j < i; ++j)
          pddiscountfactors[i* block_size + b] *= pdexpres[j * block_size + b];
  }

  constexpr price HJM_Swaption_Blocking(const parm& swaption,
                                         long irndseed,
                                         const int& ltrials) {
    price pdswaptionprice;
    double dstrikecont;

    std::array<std::array<double, (m_in - 1) * block_size>, m_in - 1> ppdhjmpath; 
    std::array<double, m_in - 1> pdforward;
    std::array<double, m_in - 1> pdtotaldrift;
    std::array<double, (m_in - 1) * block_size> pddiscountingratepath;
    std::array<double, (m_in - 1) * block_size> pdpayoffdiscountfactors;

    double dswaptionpayoff;
    double ddiscswaptionpayoff, dfixedlegvalue;

    double ddelt = (double)(swaption.dyears / m_in);
    int ifreqratio = swaption.dpaymentinterval / ddelt + 0.5f;

    if (swaption.dcompounding == 0) {
      dstrikecont = swaption.dstrike;
    } else {
      dstrikecont = (1 / swaption.dcompounding) * 
                    cexpr_log(1 + swaption.dstrike * swaption.dcompounding);
    }

    int iswapvectorlength = m_in - swaption.dmaturity / ddelt + 0.5f;

    cest::vector<double> pdswapratepath;
    pdswapratepath.resize(iswapvectorlength * block_size);
    cest::vector<double> pdswapdiscountfactors;
    pdswapdiscountfactors.resize(iswapvectorlength * block_size);
    cest::vector<double> pdswappayoffs;
    pdswappayoffs.resize(iswapvectorlength);

    int iswapstarttimeindex = swaption.dmaturity / ddelt + 0.5f;
    int iswaptimepoints = swaption.dtenor / ddelt + 0.5f;
    double dswapvectoryears = iswapvectorlength * ddelt;

    for (int i = 0; i < pdswappayoffs.size(); ++i)
      pdswappayoffs[i] = 0.0f;

    for (int i = ifreqratio; i <= iswaptimepoints; i += ifreqratio) {
      if (i != iswaptimepoints)
        pdswappayoffs[i] = cexpr_exp(dstrikecont * swaption.dpaymentinterval)-1;
      if (i == iswaptimepoints)
        pdswappayoffs[i] = cexpr_exp(dstrikecont * swaption.dpaymentinterval);
    }

    HJM_Yield_To_Forward(pdforward, swaption.pdyield);
    
    HJM_Drifts(pdtotaldrift, swaption.dyears, swaption.ppdfactors);
    
    double dsumsimswaptionprice = 0.0f;
    double dsumsquaresimswaptionprice = 0.0f;

    for (int l = 0; l < ltrials; l += block_size) {
      // 51% of the time in this one function
      // should now be correct just slight precision errors possibly caused by 
      // the cest functions inside of CumNormalInv
      HJM_SimPath_Forward_Blocking(ppdhjmpath, swaption.dyears, pdforward, 
                                   pdtotaldrift, swaption.ppdfactors, irndseed);

      for (int i = 0; i < m_in - 1; ++i)
        for (int b = 0; b < block_size; ++b)
          pddiscountingratepath[block_size * i + b] = ppdhjmpath[i][b];

      Discount_Factors_Blocking(pdpayoffdiscountfactors, m_in, swaption.dyears,
                                pddiscountingratepath);

      for (int i = 0; i < iswapvectorlength; ++i)
        for (int b = 0; b < block_size; ++b)
          pdswapratepath[i * block_size + b] = 
            ppdhjmpath[iswapstarttimeindex][i * block_size + b];

      Discount_Factors_Blocking(pdswapdiscountfactors, iswapvectorlength, 
                                dswapvectoryears, pdswapratepath);

      for (int b = 0; b < block_size; ++b) {
        dfixedlegvalue = 0.0;
        for (int i = 0; i < iswapvectorlength; ++i)
          dfixedlegvalue += pdswappayoffs[i] * 
                            pdswapdiscountfactors[i * block_size + b];

        dswaptionpayoff = std::max(dfixedlegvalue - 1.0, 0.0);
        ddiscswaptionpayoff = dswaptionpayoff 
                * pdpayoffdiscountfactors[iswapstarttimeindex * block_size + b];

        dsumsimswaptionprice += ddiscswaptionpayoff;
        dsumsquaresimswaptionprice += ddiscswaptionpayoff * ddiscswaptionpayoff;
      }
    }

    pdswaptionprice.dsimswaptionmeanprice = dsumsimswaptionprice / ltrials;
    pdswaptionprice.dsimswaptionstderror = (double)cexpr_sqrt(
      (dsumsquaresimswaptionprice - dsumsimswaptionprice 
       * dsumsimswaptionprice / (double)ltrials) / ((double)ltrials - 1.0f))
        / cexpr_sqrt((double)ltrials);

    return pdswaptionprice;
  }

  constexpr auto calc() {
    std::array<std::array<double, m_in - 1>, m_ifactors> factors{};
    std::array<parm, nswaptions> swaptions;
    std::array<price, nswaptions> prices;

    factors[0][0] = .01;
    factors[0][1] = .01;
    factors[0][2] = .01;
    factors[0][3] = .01;
    factors[0][4] = .01;
    factors[0][5] = .01;
    factors[0][6] = .01;
    factors[0][7] = .01;
    factors[0][8] = .01;
    factors[0][9] = .01;

    factors[1][0] = .009048;
    factors[1][1] = .008187;
    factors[1][2] = .007408;
    factors[1][3] = .006703;
    factors[1][4] = .006065;
    factors[1][5] = .005488;
    factors[1][6] = .004966;
    factors[1][7] = .004493;
    factors[1][8] = .004066;
    factors[1][9] = .003679;

    factors[2][0] = .001000;
    factors[2][1] = .000750;
    factors[2][2] = .000500;
    factors[2][3] = .000250;
    factors[2][4] = .000000;
    factors[2][5] = -.000250;
    factors[2][6] = -.000500;
    factors[2][7] = -.000750;
    factors[2][8] = -.001000;
    factors[2][9] = -.001250;
    
    long seed = 1979;
    long swaption_seed = 2147483647L * RanUnif(seed);
    
    // not good loop to parallelize as RanUnif needs to be invoked in the same 
    // order to get a determinate result, but it's likely fine if extracted into
    // a seperate loop
    for (int i = 0; i < nswaptions; ++i) {
      swaptions[i].dyears = 5.0 + ((int)(60*RanUnif(seed)))*0.25;
      swaptions[i].dstrike = 0.1 + ((int)(49*RanUnif(seed))) * 0.1;
      swaptions[i].dcompounding = 0;
      swaptions[i].dmaturity = 1.0;
      swaptions[i].dtenor = 2.0;
      swaptions[i].dpaymentinterval = 1.0;
      
      swaptions[i].pdyield[0] = .1;
      for (int j = 1; j < swaptions[i].pdyield.size(); ++j)
        swaptions[i].pdyield[j] = swaptions[i].pdyield[j-1] + .005;
    
      for(int k = 0; k < swaptions[i].ppdfactors.size(); ++k)
         for(int j = 0; j < swaptions[i].ppdfactors[k].size(); ++j) {;
           swaptions[i].ppdfactors[k][j] = factors[k][j];
         }
    }


#ifdef CONSTEXPR_TRACK_TIME
    __GetTimeStampStart();
#endif

// Remember the extra steps over the linear version in this case are for the 
// "marshalling"/preparation of data, the two functions cost about 15 steps
#ifdef CONSTEXPR_TRACK_STEPS
    __TrackConstExprStepsStart();
#endif CONSTEXPR_TRACK_STEPS

#ifdef CONSTEXPR_PARALLEL
    // The range will very likely be small with minimal work, no real reason to
    // parallelize it. 
    std::array<int, nswaptions> id_range{};
    std::iota(id_range.begin(), id_range.end(), 0); 
    std::for_each(execution::ce_par, id_range.begin(), id_range.end(), 
      [&prices, &swaptions, swaption_seed](auto& id) mutable {
          prices[id] = HJM_Swaption_Blocking(swaptions[id], swaption_seed + id, 
                                             num_trials);
    });
#else
    for (int i = 0; i < swaptions.size(); ++i)
      prices[i] = HJM_Swaption_Blocking(swaptions[i], swaption_seed+i, 
                                        num_trials);
#endif

#ifdef CONSTEXPR_TRACK_STEPS
    __PrintConstExprSteps(); 
#endif CONSTEXPR_TRACK_STEPS

#ifdef CONSTEXPR_TRACK_TIME
    __GetTimeStampEnd();
    __PrintTimeStamp();
#endif 

    return prices;
  }
} // namespace swaptions

int main() {
  constexpr auto out = swaptions::calc();

  // I've compared the results against the original ParSec benchmark (blocking 
  // version) and the results are correct. Compared with the following 
  // invocation: ./swaptions -ns 4 -sd 1979 -sm 10240
  //
  // results were:
  //  Swaption 0: [SwaptionPrice: 6.9320352370 StdError: 0.0012609785] 
  //  Swaption 1: [SwaptionPrice: 3.2389479790 StdError: 0.0008797101] 
  //  Swaption 2: [SwaptionPrice: 0.8545941705 StdError: 0.0003274391] 
  //  Swaption 3: [SwaptionPrice: 6.4801674240 StdError: 0.0016718084]
  for (int i = 0; i < out.size(); ++i) { 
     fprintf(stderr,"Swaption %d: [SwaptionPrice: %.10lf StdError: %.10lf] \n", 
             i, out[i].dsimswaptionmeanprice, 
                out[i].dsimswaptionstderror);
  }
  
  return 0;
}
