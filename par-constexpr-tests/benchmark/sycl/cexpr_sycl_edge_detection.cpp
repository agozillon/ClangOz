#include <CL/sycl.hpp>
#include <iostream>
#include <fstream>
#include <cmath>
#include <array>
#include <memory>

#include "cest/vector.hpp"

#include "image_header_out.h"

#include "../../helpers/sqrt/cexpr_sqrt.hpp"

// Based on the DPC++ SYCL example here, thank you for the example:
// https://www.codeproject.com/Articles/5284847/5-Minutes-to-Your-First-oneAPI-App-on-DevCloud 
//
// There's a prebuilt image_header_out.h, however you can generate a new one 
// from another image using the program generated from: image_to_text_file.cpp 
// this external program also performs the greyscaling of the image at the 
// moment. So the header is a greyscale image.
//
// All it is doing is using OpenCV to open an image and spit it out into a 
// header that can then be compiled into this program (can't read in data at 
// compile time just yet). As a side affect anytime you'd like to change the 
// image you will have to recompile this program as the data is pre-baked into 
// the executeable at compilation (that's all we really care about in our case
// though for the moment).
//
//
// NOTE: Can't use libcxx with the normal linux install of OpenCV as it was 
// compiled with libstdc++, at the very least the string ABI isn't compatible so
// you cannot use functions like cv::imwrite.
 
// $CLANGOZ/bin/clang++ -D_LIBCPP_HAS_PARALLEL_ALGORITHMS -O3 -DCONSTEXPR_PARALLEL \ 
// -fconstexpr-steps=4294967295 -w -fconstexpr-parallel-partition-size=4 \ 
// -fexperimental-constexpr-parallel -I$PSTL_GEN -I$CEST_INCLUDE \ 
// -I$MOTORSYCL_INCLUDE -I$PSTL -std=c++2a -stdlib=libc++  cexpr_sycl_edge_detection.cpp

using namespace cl::sycl;

bool WriteToPPM(auto buffer, std::string fname) {
  std::ofstream ofs; 
  ofs.open(fname);

  // ppm image type header
  ofs << "P3\n";
  ofs << width << " " << height << " \n";
  ofs << "255\n";

  for (size_t x = 0; x < width; ++x)
    for (size_t y = 0; y < height; ++y)
     ofs << buffer[x + width * y] << " " << buffer[x + width * y] << " " << buffer[x + width * y] << "\n";
    
    
  ofs.close(); 

  return true;
}

// breaking these into segments so I can work problems out in phases.
constexpr auto perform_horizontal_conv(cl::sycl::queue &myQueue,
    cl::sycl::buffer<unsigned int, 1>& a, cl::sycl::buffer<float, 1>& dx) {
  // horizontal convolution
    std::array<float, height * width> tmp{};
    buffer<float, 1> dx_tmp{tmp.data(), width * height};
  
  {
    // Extract a 3x1 window around (x, y) and compute the dot product
    // between the window and the kernel [1, 0, -1]
    myQueue.submit([&](handler& cgh) {
#if defined(SYCL_LANGUAGE_VERSION) && defined(__MOTORSYCL__)
      auto data = a.get_access<access_mode::read>(cgh);
      auto out = dx_tmp.get_access<access_mode::write>(cgh);
#else
      auto data = a.get_access<access::mode::read>(cgh);
      auto out = dx_tmp.get_access<access::mode::write>(cgh);
#endif

      // does this iterate more than once at compile time...? because i can write to it = Yes it appears to..
      // are the id's correct at compile time...? because i can assign to other locations using faked ids = ID is scuffed! 
      cgh.parallel_for(range<2>(width, height), [=](id<2> idx) {
           int offset = idx[1] * width + idx[0];
           float left = idx[0] == 0 ? 0 : data[id(offset - 1)]; 
           float right = idx[0] == width - 1 ? 0 : data[id(offset + 1)];
           out[id(offset)] = left - right;
        });
    });
  }

  // fails within the first 8 elements, the last 4 are not assigned
  myQueue.wait();

  {
  // Extract a 1x3 window around (x, y) and compute the dot product
  // between the window and the kernel [1, 2, 1]    
  myQueue.submit([&](handler& cgh) {
#if defined(SYCL_LANGUAGE_VERSION) && defined(__MOTORSYCL__)
    auto data = dx_tmp.get_access<access_mode::read>(cgh);
    auto out = dx.get_access<access_mode::discard_write>(cgh);
#else
    auto data = dx_tmp.get_access<access::mode::read>(cgh);
    auto out = dx.get_access<access::mode::discard_write>(cgh);
#endif

    cgh.parallel_for(range<2>(width, height),
          [=](id<2> idx) {
            // Convolve vertically
            int offset = idx[1] * width + idx[0];
            float up   = idx[1] == 0 ? 0 : data[id(offset - width)];
            float down = idx[1] == height - 1 ? 0 : data[id(offset + width)];
            float center = data[id(offset)];
            out[id(offset)]  = up + 2 * center + down;
      });
  });
  
  }
  
  myQueue.wait();
}
 
constexpr void perform_vertical_conv(cl::sycl::queue &myQueue, 
        cl::sycl::buffer<unsigned int, 1>& a, cl::sycl::buffer<float, 1>& dy) {
  // vertical convolution
  std::array<float, height * width> tmp{};
  buffer<float, 1> dy_tmp{tmp.data(), width * height};
  
  {
    myQueue.submit([&](handler& cgh) {
  #if defined(SYCL_LANGUAGE_VERSION) && defined(__MOTORSYCL__)
    auto data = a.get_access<access_mode::read>(cgh);
    auto out  = dy_tmp.get_access<access_mode::discard_write>(cgh);
  #else
    auto data = a.get_access<access::mode::read>(cgh);
    auto out  = dy_tmp.get_access<access::mode::discard_write>(cgh);
  #endif

    // Create a scratch buffer for the intermediate computation
    cgh.parallel_for(range<2>(width, height), 
        [=](id<2> idx) {
           // Convolve horizontally
           int offset = idx[1] * width + idx[0];
           float left = idx[0] == 0 ? 0 : data[id(offset - 1)];
           float right = idx[0] == width - 1 ? 0 : data[id(offset + 1)];
           float center = data[id(offset)];
           out[id(offset)]  = left + 2 * center + right;
        });
    });
  }
  
  myQueue.wait();
  
  {
    myQueue.submit([&](handler& cgh) {
  #if defined(SYCL_LANGUAGE_VERSION) && defined(__MOTORSYCL__)
      auto data = dy_tmp.get_access<access_mode::read>(cgh);
      auto out  = dy.get_access<access_mode::discard_write>(cgh);
  #else
      auto data = dy_tmp.get_access<access::mode::read>(h);
      auto out  = dy.get_access<access::mode::discard_write>(h);
  #endif

        cgh.parallel_for(range<2>(width, height),
            [=](id<2> idx) {
                // Convolve vertically
                int offset = idx[1] * width + idx[0];
                float up   = idx[1] == 0 ? 0 : data[id(offset - width)];
                float down = idx[1] == height - 1 ? 0 : data[id(offset + width)];
                out[id(offset)] = up - down;
            });
    });
  }
  
  myQueue.wait();
}

constexpr auto apply_filter(cl::sycl::queue &myQueue, 
                            cl::sycl::buffer<unsigned int, 1>& a,
                            cl::sycl::buffer<unsigned int, 1>& b,
                            cl::sycl::buffer<float, 1>& dx,
                            cl::sycl::buffer<float, 1>& dy) {
  {
    myQueue.submit([&](handler& cgh) {
  #if defined(SYCL_LANGUAGE_VERSION) && defined(__MOTORSYCL__)
        auto dx_d = dx.get_access<access_mode::read>(cgh);
        auto dy_d = dy.get_access<access_mode::read>(cgh);
        // this was previously shared memory, so I hope this doesn't affect the 
        // outcome of the program at least for CPU
        auto out = b.get_access<access_mode::write>(cgh);
  #else
        auto dx_d = dx.get_access<access::mode::read>(cgh);
        auto dy_d = dy.get_access<access::mode::read>(cgh);
        // this was previously shared memory, so I hope this doesn't affect the 
        // outcome of the program at least for CPU
        auto out = b.get_access<access::mode::write>(cgh);
  #endif
        cgh.parallel_for(range<1>(width * height), [=](id<1> idx) {
            float dx_val = dx_d[id(idx[0])];
            float dy_val = dy_d[id(idx[0])];
          
            // in the original dpc++ sycl example this was multiplied by 255, 
            // but that yields incorrect results here. This may be due to the 
            // lack of shared memory, or there is perhaps a difference in the 
            // way we handle input data
            out[id(idx[0])] = cexpr_sqrtf(dx_val * dx_val + dy_val * dy_val);
        });
   });
  }
  myQueue.wait();

#if defined(SYCL_LANGUAGE_VERSION) && defined(__MOTORSYCL__)
  host_accessor B { b, read_only };
#else
  auto B = b.get_access<access::mode::read>();
#endif

  std::array<unsigned int, width * height> final_data{};
  for (int i = 0; i < final_data.size(); ++i) {
    final_data[i] = B[i];
  }

  return final_data;
}

// step through with debugger at runtime, try find the path/issue it has
constexpr auto edge_detect() {
  // Create a queue to work on
  queue myQueue;

  // these do constexpr initialization, better than using a normal array where 
  // we'd have to deal with that! 
  std::array<unsigned int, width * height> data{};
  std::array<unsigned int, width * height> out_data{};

  buffer<unsigned int, 1> a (data.data(), range<1>{width * height});
  buffer<unsigned int, 1> b (out_data.data(), range<1>{width * height});

  for (size_t x = 0; x < width; ++x)
    for (size_t y = 0; y < height; ++y)
     data[x + width * y] = image_data[x + width * y];

  std::array<float, width * height> dx_data{};
  std::array<float, width * height> dy_data{};

  buffer<float, 1> dx{dx_data.data(), width * height};
  buffer<float, 1> dy{dy_data.data(), width * height};

  perform_horizontal_conv(myQueue, a, dx);
  perform_vertical_conv(myQueue, a, dy);
  return apply_filter(myQueue, a, b, dx, dy);
}

int main()
{
  // print before, which is already pre-greyscaled, technically we can also 
  // greyscale within this application, rather than in the image_to_text_file
  WriteToPPM(image_data, "input_header_test.ppm");

  constexpr auto B = edge_detect();

  WriteToPPM(B, "out_image.ppm");

  return 0;
}
