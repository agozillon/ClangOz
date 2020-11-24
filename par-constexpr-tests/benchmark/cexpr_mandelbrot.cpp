#include <array>
#include <algorithm>
#include <numeric>
#include <iostream>
#include <fstream>
#include <type_traits>
#include <execution>
#include <complex>

using namespace __cep::experimental;

#include "cest/cmath.hpp"

// need to set: ulimit -s unlimited for this
//even with 4294967295 steps 2048x2048 is too big 

#include "../helpers/sqrt/cexpr_sqrt.hpp"

namespace mandelbrot {
  using fcomplex_t = std::complex<double>;

  constexpr int width = 256;
  constexpr int height = 256;
  constexpr int maxiters = 255;
  constexpr double minx = (- (1.5f));
  constexpr double maxx = (0.5f);
  constexpr double miny = (- (1.0f));
  constexpr double maxy = (1.0f);
  constexpr double xincr = ((maxx - minx) / width); 
  constexpr double yincr = ((maxy - miny) / height);

  template<typename T>
  inline constexpr auto complex_add(const std::complex<T>& v, 
                                    const std::complex<T>& v2) {
    return std::complex<T>(v.real() + v2.real(), v.imag() + v2.imag()); 
  }
  
  // borrowed from the libcxx complex operator* minus a lot of builtin usage 
  // that would make constexpr a pain
  template<typename T>
  inline constexpr auto complex_mult(const std::complex<T>& v, 
                                     const std::complex<T>& v2) {
    T __a = v.real();
    T __b = v.imag();
    T __c = v2.real();
    T __d = v2.imag();
    T __ac = __a * __c;
    T __bd = __b * __d;
    T __ad = __a * __d;
    T __bc = __b * __c;
    T __x = __ac - __bd;
    T __y = __ad + __bc;
    
    return std::complex<T>(__x, __y); 
  }
  
  template<typename T>
  inline constexpr T complex_abs(const std::complex<T>& v) {
    return cexpr_sqrt(v.real()*v.real() + v.imag()*v.imag());
  }
  
  constexpr int mand_cmplx(fcomplex_t& c) {
    fcomplex_t z = c;
    int t = maxiters, n = 0;

    while (true) {
      double tmpF220 = complex_abs(z);
      if (((tmpF220 >= (2.0f)) || (n >= maxiters))) {
        break;
      }

      z = complex_add(complex_mult(z, z), c);
      n++;
    }

    if ((n < maxiters))
      t = n;

    return t;
  }

  // same function, just linear without the need for an id_range so it's 
  // a more accurate benchmark (the parallel version needs it this does not, 
  // so it's unfair to criple its time)
  constexpr bool ComputeComplexIncrLinear(auto& cs) {
    for (unsigned int i = 0; i < width; ++i)
      for (unsigned int j = 0; j < height; ++j)
        cs[i][j] = fcomplex_t((i * xincr) + minx, (j * yincr) + miny);

    return true;
  }
  
  constexpr bool ComputeComplexIncr(auto& cs, auto id_range) {
//    std::array<int, width> id_rangez{};
//    std::iota(execution::ce_par, id_rangez.begin(), id_rangez.end(), 0);
    
    // currently we do not parallelize more than 1 depth
    std::for_each(execution::ce_par, id_range.begin(), id_range.end(), 
      [&cs](auto id) mutable {
        for (unsigned int j = 0; j < height; ++j)
          cs[id][j] = fcomplex_t((id * xincr) + minx, (j * yincr) + miny);
    });

    return true;
  }

  // same function, just linear without the need for an id_range so it's 
  // a more accurate benchmark (the parallel version needs it this does not, 
  // so it's unfair to criple its time)
  constexpr bool ComputeMandelBrotLinear(auto& cs, auto& sb) {
    for (unsigned int i = 0; i < width; ++i)
      for (unsigned int j = 0; j < height; ++j)
        sb[i][j] = mand_cmplx(cs[i][j]);

    return true;
  }
  
  constexpr bool ComputeMandelBrot(auto& cs, auto& sb, auto id_range) {
    // currently we do not parallelize more than 1 depth
    std::for_each(execution::ce_par, id_range.begin(), id_range.end(), 
      [&cs, &sb](auto id) mutable {
        for (unsigned int j = 0; j < height; ++j)
          sb[id][j] = mand_cmplx(cs[id][j]);
    });

    return true;
  }

  constexpr auto calc() {
    std::array<std::array<int, height>, width> sb{};
    std::array<std::array<fcomplex_t, height>, width> cs{};

#ifdef CONSTEXPR_PARALLEL
    std::array<int, width> id_range{};
    std::iota(execution::ce_par, id_range.begin(), id_range.end(), 0);
    ComputeComplexIncr(cs, id_range);
    ComputeMandelBrot(cs, sb, id_range);
#else
    ComputeComplexIncrLinear(cs);
    ComputeMandelBrotLinear(cs, sb);
#endif

    return sb;
  }

} // namespace mandelbrot

bool WriteToPPM(auto buffer, std::string fname) {
  std::ofstream ofs; 
  ofs.open(fname);

  // ppm image type header
  ofs << "P3\n";
  ofs << buffer.size() << " " << buffer[0].size() << " \n";
  ofs << "255\n";

  for (int i = 0; i < buffer.size(); ++i)
    for (int j = 0; j < buffer[i].size(); ++j) {
     ofs << buffer[i][j] << " " << buffer[i][j] << " " << buffer[i][j] << "\n";
    }
  ofs.close(); 

  return true;
}

// Steps:
// 1) get it working in constexpr
// 2) add for_each functions/transform etc
// 3) add ability to swap to parallel constexpr
int main() {
  constexpr auto out = mandelbrot::calc();
  WriteToPPM(out, "mandelbrot.ppm");
  
  return 0;
}
