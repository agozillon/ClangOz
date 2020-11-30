#include <array>
#include <algorithm>
#include <numeric>
#include <iostream>
#include <fstream>
#include <type_traits>
#include <execution>
#include <complex>

using namespace __cep::experimental;

#include "../helpers/sqrt/cexpr_sqrt.hpp"
#include "cest/cmath.hpp"

namespace nbody {
  using type = double;

  constexpr int niters = 500000; // 22 mins~
  constexpr int nbodies = 5;
  
  constexpr type pi = 3.141592653589793;
  constexpr type solar_mass = 4 * pi * pi;
  constexpr type days_per_year = 365.24;
  constexpr type dt = 0.01;

  template <typename T>
  struct planet {
    T x, y, z;
    T vx, vy, vz;
    T mass;
  };

  constexpr std::array<planet<type>, 5> golden_bodies = {{
   {0, 0, 0, 0, 0, 0, solar_mass}, /* sun */ 
   {                          /* jupiter */
      static_cast<type>(4.84143144246472090e+00),
       static_cast<type>(-1.16032004402742839e+00),
       static_cast<type>(-1.03622044471123109e-01),
       static_cast<type>(1.66007664274403694e-03 * days_per_year),
       static_cast<type>(7.69901118419740425e-03 * days_per_year),
       static_cast<type>(-6.90460016972063023e-05 * days_per_year),
       static_cast<type>(9.54791938424326609e-04 * solar_mass)
    },
    {                               /* saturn */
       static_cast<type>(8.34336671824457987e+00),
       static_cast<type>(4.12479856412430479e+00),
       static_cast<type>(-4.03523417114321381e-01),
       static_cast<type>(-2.76742510726862411e-03 * days_per_year),
       static_cast<type>(4.99852801234917238e-03 * days_per_year),
       static_cast<type>(2.30417297573763929e-05 * days_per_year),
       static_cast<type>(2.85885980666130812e-04 * solar_mass)
    },
    {                               /* uranus */
       static_cast<type>(1.28943695621391310e+01),
      -static_cast<type>(1.51111514016986312e+01),
      -static_cast<type>(2.23307578892655734e-01),
       static_cast<type>(2.96460137564761618e-03 * days_per_year),
       static_cast<type>(2.37847173959480950e-03 * days_per_year),
      -static_cast<type>(2.96589568540237556e-05 * days_per_year),
       static_cast<type>(4.36624404335156298e-05 * solar_mass)
    },
    {                               /* neptune */
       static_cast<type>(1.53796971148509165e+01),
       static_cast<type>(-2.59193146099879641e+01),
       static_cast<type>(1.79258772950371181e-01),
       static_cast<type>(2.68067772490389322e-03 * days_per_year),
       static_cast<type>(1.62824170038242295e-03 * days_per_year),
       static_cast<type>(-9.51592254519715870e-05 * days_per_year),
       static_cast<type>(5.15138902046611451e-05 * solar_mass)
    }
  }};

  // perhaps look into softening and better sqrt for cest
  template <typename T, unsigned long N>
  constexpr void Advance(std::array<planet<T>, N>& bodies, T dt) {
    const T eps = T{0.1}; // softening factor

#ifdef CONSTEXPR_PARALLEL
    std::array<int, N> id_range{};
    std::iota(execution::ce_par, id_range.begin(), id_range.end(), 0);

    std::for_each(execution::ce_par, id_range.begin(), id_range.end(), 
        [dt, eps, &bodies](auto id) mutable {
        for (int j = 0; j < bodies.size(); j++) {
          if (id==j)
            continue;
          T dx = bodies[id].x - bodies[j].x;
          T dy = bodies[id].y - bodies[j].y;
          T dz = bodies[id].z - bodies[j].z;
          T distance = cexpr_sqrt(dx * dx + dy * dy + dz * dz/* + eps*/);
          T mag = dt / (distance * distance * distance);
          bodies[id].vx  -= dx * bodies[j].mass * mag;
          bodies[id].vy  -= dy * bodies[j].mass * mag;
          bodies[id].vz  -= dz * bodies[j].mass * mag;
        }
    });
#else
    for (int i = 0; i < bodies.size(); ++i) {
      for (int j = 0; j < bodies.size(); j++) {
        if (i==j)
          continue;
        T dx = bodies[i].x - bodies[j].x;
        T dy = bodies[i].y - bodies[j].y;
        T dz = bodies[i].z - bodies[j].z;
        T distance = cexpr_sqrt(dx * dx + dy * dy + dz * dz /*+ eps*/);
        T mag = dt / (distance * distance * distance);
        bodies[i].vx  -= dx * bodies[j].mass * mag;
        bodies[i].vy  -= dy * bodies[j].mass * mag;
        bodies[i].vz  -= dz * bodies[j].mass * mag;
      }
    }
#endif

#ifdef CONSTEXPR_PARALLEL
    std::for_each(execution::ce_par, bodies.begin(), bodies.end(), 
      [dt](auto& b) mutable {
        b.x += dt * b.vx;
        b.y += dt * b.vy;
        b.z += dt * b.vz;
    });
#else
    for (int i = 0; i < bodies.size(); ++i) {
      planet<T> &b = bodies[i];
      b.x += dt * b.vx;
      b.y += dt * b.vy;
      b.z += dt * b.vz;
    }
#endif
  }

  template <typename T, unsigned long N>
  constexpr T Energy(std::array<planet<T>, N> bodies) {
    T e = 0.0;

    // this can be converted to something similar to the loops in the Advance
    // function, however the accumulation and decrementation of energy in e
    // makes this difficult to parallelize sadly.
    for (int i = 0; i < bodies.size(); ++i) {
      planet<T> &b = bodies[i];
      e += 0.5 * b.mass * (b.vx * b.vx + b.vy * b.vy + b.vz * b.vz);
      for (int j = i + 1; j < bodies.size(); j++) {
        planet<T> &b2 = bodies[j];
        T dx = b.x - b2.x;
        T dy = b.y - b2.y;
        T dz = b.z - b2.z;
        T distance = cexpr_sqrt(dx * dx + dy * dy + dz * dz);
        e -= (b.mass * b2.mass) / distance;
      }
    }

    return e;
  }

  template <typename T, unsigned long N>
  constexpr void Offset_Momentum(std::array<planet<T>, N>& bodies) {
    T px = 0.0, py = 0.0, pz = 0.0;

    for (int i = 0; i < bodies.size(); ++i) {
      px += bodies[i].vx * bodies[i].mass;
      py += bodies[i].vy * bodies[i].mass;
      pz += bodies[i].vz * bodies[i].mass;
    }

    bodies[0].vx = - px / solar_mass;
    bodies[0].vy = - py / solar_mass;
    bodies[0].vz = - pz / solar_mass;
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
  
  template <typename T, unsigned long N>
  constexpr void Init_Random_Bodies(std::array<planet<T>, N>& bodies) {
    long seed = 1992;
    for (int i = 0; i < bodies.size(); ++i) {
      bodies[i].x    = RanUnif(seed);
      bodies[i].y    = RanUnif(seed);
      bodies[i].z    = RanUnif(seed);
      bodies[i].vx   = RanUnif(seed);
      bodies[i].vy   = RanUnif(seed);
      bodies[i].vz   = RanUnif(seed);
      bodies[i].mass = RanUnif(seed);
    }
  }

  template <bool UseGolden>
  constexpr auto Get_Bodies() {
    if constexpr (UseGolden) {
      return golden_bodies;
    } else {
      std::array<planet<type>, nbodies> arr;
      Init_Random_Bodies(arr);
      return arr;
    }
  }
  
  template <bool UseGolden = true>
  constexpr auto Calc() {
    // likely don't need to parallelize these, it would only be efficient with
    // a large number of nbodies.
    auto bodies = Get_Bodies<UseGolden>();
    Offset_Momentum(bodies);
    auto e1 = Energy(bodies);

    for (int i = 1; i <= niters; ++i)
      Advance(bodies, dt);

    auto e2 = Energy(bodies);

    return std::pair<type, type>(e1, e2);
  }
}

// The source for this is the benchmarks game, the progenitor of which is 
// the alioth benchmarks (mandelbrot also came from here): 
// https://benchmarksgame-team.pages.debian.net/benchmarksgame/program/nbody-gcc-1.html
//
// //The code began as "C gcc #2":
//http://benchmarksgame.alioth.debian.org/u64q/program.php?test=nbody&lang=gcc&id=2
//Actually, this "C gcc (#1)" is a better (simpler) base version:
//https://benchmarksgame.alioth.debian.org/u64q/program.php?test=nbody&lang=gcc&id=


int main() {
  constexpr auto outData = nbody::Calc();

  // the golden values from the alioth benchmark for 500000 iterations, the 
  // provided number of iterations in the test on the website are a little too 
  // large for constexpr tests, we run out of steps after an hour:
  //
  // -0.169075164
  // -0.169096567
  //
  // the results appear to be accurate at compile time and runtime!

  // The results are a little different from the runtime version this is based 
  // on, mainly due to the use of cest::sqrt over std::sqrt as there is no 
  // constexpr std::sqrt at this time. I have however tested the runtime output
  // with std::sqrt and it's identical.
  std::cout << std::setprecision(9);
  std::cout << "Returned Energy 1: "<< std::get<0>(outData) << "\n";
  std::cout << "Returned Energy 2: "<< std::get<1>(outData) << "\n";
  return 0;
}
