#include <CL/sycl.hpp>
#include <iostream>
#include <fstream>
#include <cmath>
#include <array>
#include <memory>

using namespace cl::sycl;

constexpr auto vector_add() {
  queue myQueue;
  
  std::array<int, 10> v1{1,2,3,4,5,6,7,8,9,10};
  std::array<int, 10> v2{1,2,3,4,5,6,7,8,9,10};
  std::array<int, 10> out{};
  
  buffer<int, 1> v1_buff{v1.data(), 10};
  buffer<int, 1> v2_buff{v2.data(), 10};
  buffer<int, 1> out_buff{out.data(), 10};
  
  {
    // Extract a 3x1 window around (x, y) and compute the dot product
    // between the window and the kernel [1, 0, -1]
    myQueue.submit([&](handler& cgh) {
#if defined(SYCL_LANGUAGE_VERSION) && defined(__MOTORSYCL__)
      auto v1_acc = v1_buff.get_access<access_mode::read>(cgh);
      auto v2_acc = v2_buff.get_access<access_mode::read>(cgh);
      auto out_acc = out_buff.get_access<access_mode::write>(cgh);
#else
      auto v1_acc = v1_buff.get_access<access::mode::read>(cgh);
      auto v2_acc = v2_buff.get_access<access::mode::read>(cgh);
      auto out_acc = out_buff.get_access<access::mode::write>(cgh);
#endif

      // does this iterate more than once at compile time...? because i can write to it = Yes it appears to..
      // are the id's correct at compile time...? because i can assign to other locations using faked ids = ID is scuffed! 
      cgh.parallel_for(range<1>(10), [=](id<1> idx) {
          out_acc[idx] = v1_acc[idx] + v2_acc[idx];
        });
    });
  }
  
    myQueue.wait();
    
    return out;
}

int main() {
  
  constexpr auto B = vector_add();
  
  for (int i = 0; i < B.size(); ++i)
    std::cout << "B vals: " << B[i] << "\n";
    
  return 0;
}
