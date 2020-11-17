#include <array>
#include <algorithm>
#include <iostream>
#include <fstream>
#include <type_traits>
#include <execution>
#include <complex>

using namespace __cep::experimental;

#include "cest/cmath.hpp"

namespace nbody {
  using type = double;

  constexpr int niters = 1000;
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

//https://developer.nvidia.com/gpugems/gpugems3/part-v-physics-simulation/chapter-31-fast-n-body-simulation-cuda 
//  __device__ float3 bodyBodyInteraction(float4 bi, float4 bj, float3 ai) {   
//    float3 r;
//    r.x = bj.x - bi.x;
//    r.y = bj.y - bi.y;
//    r.z = bj.z - bi.z;
//    float distSqr = r.x * r.x + r.y * r.y + r.z * r.z + EPS2;   
//    float distSixth = distSqr * distSqr * distSqr;   
//    float invDistCube = 1.0f/sqrtf(distSixth);
//    float s = bj.w * invDistCube; // mass * mag
//    ai.x += r.x * s;   
//    ai.y += r.y * s;   
//    ai.z += r.z * s;   
//    return ai; 
//  } 

//  // the cuda version executes one of these per thread
//  __device__ float3 tile_calculation(float4 myPosition, float3 accel) {   
//    int i;   
//    extern __shared__ float4[] shPosition;   
//    
//    for (i = 0; i < blockDim.x; i++) {     
//      accel = bodyBodyInteraction(myPosition, shPosition[i], accel);   
//    }   
//    
//    return accel; 
//  }
//  
//  __global__ void calculate_forces(void *devX, void *devA) {   
//    extern __shared__ float4[] shPosition;   
//    float4 *globalX = (float4 *)devX;
//   float4 *globalA = (float4 *)devA;
//   float4 myPosition;   
//   int i, tile;   
//   float3 acc = {0.0f, 0.0f, 0.0f};
//   int gtid = blockIdx.x * blockDim.x + threadIdx.x; 
//   myPosition = globalX[gtid];   
//   for (i = 0, tile = 0; i < N; i += p, tile++) {     
//      int idx = tile * blockDim.x + threadIdx.x;     
//      shPosition[threadIdx.x] = globalX[idx];
//      __syncthreads();     
//      acc = tile_calculation(myPosition, acc);    
//      __syncthreads();   
//    }   
//    
//      // Save the result in global memory for the integration step.    
//      float4 acc4 = {acc.x, acc.y, acc.z, 0.0f};   
//      globalA[gtid] = acc4; 
//    }
//      

//  template <typename T, unsigned long N>
//  constexpr void Advance(std::array<planet<T>, N>& bodies, T dt) {
//    int i, j;

//    auto body_work = [](auto bi, auto bj) {

//    };

//    for (i = 0; i < bodies.size(); ++i)
//      for (j = i + 1; j < bodies.size(); j++)
//        body_work(bodies[i], bodies[j], );

//    for (i = 0; i < bodies.size(); ++i)
//      for (j = i + 1; j < bodies.size(); j++) {
////        if (i == j)
////          continue;
//        planet<T> &b = bodies[i];
//        planet<T> &b2 = bodies[j];
//        T dx = b.x - b2.x;
//        T dy = b.y - b2.y;
//        T dz = b.z - b2.z;
//        T distance = cest::sqrt(dx * dx + dy * dy + dz * dz);
//        T mag = dt / (distance * distance * distance);
//        b.vx  -= dx * b2.mass * mag;
//        b.vy  -= dy * b2.mass * mag;
//        b.vz  -= dz * b2.mass * mag;
//        b2.vx += dx * b.mass  * mag;
//        b2.vy += dy * b.mass  * mag;
//        b2.vz += dz * b.mass  * mag;
//      }
//      
//    for (i = 0; i < bodies.size(); ++i) {
//      planet<T> &b = bodies[i];
//      b.x += dt * b.vx;
//      b.y += dt * b.vy;
//      b.z += dt * b.vz;
//    }
//  }
  
  
  // perhaps look into softening and better sqrt for cest
  template <typename T, unsigned long N>
  constexpr void Advance(std::array<planet<T>, N>& bodies, T dt) {
    int i, j;

    // traverse as a triangle update two at time
    // OR
    // use if (i == j) to prevent it updating twice
    for (i = 0; i < bodies.size(); ++i) {
      planet<T> &b = bodies[i];
      for (j = i + 1; j < bodies.size(); j++) {
        planet<T> &b2 = bodies[j];
        T dx = b.x - b2.x;
        T dy = b.y - b2.y;
        T dz = b.z - b2.z;
        T distance = cest::sqrt(dx * dx + dy * dy + dz * dz);
        T mag = dt / (distance * distance * distance);
        b.vx  -= dx * b2.mass * mag;
        b.vy  -= dy * b2.mass * mag;
        b.vz  -= dz * b2.mass * mag;
        b2.vx += dx * b.mass  * mag;
        b2.vy += dy * b.mass  * mag;
        b2.vz += dz * b.mass  * mag;
      }
    }
    
    for (i = 0; i < bodies.size(); ++i) {
      planet<T> &b = bodies[i];
      b.x += dt * b.vx;
      b.y += dt * b.vy;
      b.z += dt * b.vz;
    }
  }

  template <typename T, unsigned long N>
  constexpr T Energy(std::array<planet<T>, N> bodies) {
    T e = 0.0;
    
    for (int i = 0; i < bodies.size(); ++i) {
      planet<T> &b = bodies[i];
      e += 0.5 * b.mass * (b.vx * b.vx + b.vy * b.vy + b.vz * b.vz);
      for (int j = i + 1; j < bodies.size(); j++) {
        planet<T> &b2 = bodies[j];
        T dx = b.x - b2.x;
        T dy = b.y - b2.y;
        T dz = b.z - b2.z;
        T distance = cest::sqrt(dx * dx + dy * dy + dz * dz);
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

  template <typename T, unsigned long N>
  constexpr void Init_Random_Bodies(std::array<planet<T>, N>& bodies) {
    // TODO: Implement or reuse a random number gen from swaptions or 
    // somewhere else
    for (int i = 0; i < bodies.size(); ++i) {
      bodies[i].x    = 1.0; //d1(generator);
      bodies[i].y    = 1.0; //d1(generator);
      bodies[i].z    = 1.0; //d1(generator);
      bodies[i].vx   = 1.0;//d1(generator);
      bodies[i].vy   = 1.0;//d1(generator);
      bodies[i].vz   = 1.0;//d1(generator);
      bodies[i].mass = 1.0;//d1(generator);
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
Look into std::sqrt copy from libc
then look into fixing / parallelizing advance above, Paul gave some tips i have 
written inline and the nbody_brute_force.c might give some ideas 
then find mandelbrot source or just not care and say its from benchmarksgame as well..
// The source for this is the benchmarks game, the progenitor of which is 
// the alioth benchmarks (mandelbrot also came from here): 
// https://benchmarksgame-team.pages.debian.net/benchmarksgame/program/nbody-gcc-1.html
int main() {
  constexpr auto outData = nbody::Calc();

  //Returned Energy 1: -0.169073732
  //Returned Energy 2: -0.169085017 
  
  // The results are a little different from the runtime version this is based 
  // on, mainly due to the use of cest::sqrt over std::sqrt as there is no 
  // constexpr std::sqrt at this time. I have however tested the runtime output
  // with std::sqrt and it's identical.
  std::cout << std::setprecision(9);
  std::cout << "Returned Energy 1: "<< std::get<0>(outData) << "\n";
  std::cout << "Returned Energy 2: "<< std::get<1>(outData) << "\n";
  return 0;
}
