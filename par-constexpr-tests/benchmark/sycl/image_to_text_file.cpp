/*
  This is just a helper application for converting an image to a text file that
  can then be # included as a header into the cexpr_sycl_edge_detection.cpp 
  example. As the data needs to be pre-baked into the file in someway to make it
  work as compile time! No file read/out at compile time yet unfortunately.

  $CLANG_OZ/clang++ -std=c++2a image_to_text_file.cpp -o \
    image_to_test_file `pkg-config --cflags --libs opencv4`
  
*/

// OpenCV Includes
#include <opencv2/opencv.hpp>
#include <opencv2/core/core.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/highgui/highgui.hpp>

#include <iostream>
#include <fstream>

int main(int argc, char* argv[]) {
  if (argc != 2) {
      std::cout << "Usage: " << argv[0] << " <input>\n";
      return 1;
  }

  cv::Mat inputColor = cv::imread(argv[1]);
  cv::Mat inputRaw, input;
  cv::cvtColor(inputColor, inputRaw, cv::COLOR_BGR2GRAY);
  inputRaw.convertTo(input, CV_8UC1);
  cv::imwrite("input_greyscaled.bmp", input);
    
  std::ofstream ofs; 
  ofs.open("image_header_out.h");

  ofs << "#ifndef _IMAGE_TO_TEXT_FILE_OUT_ \n";
  ofs << "#define _IMAGE_TO_TEXT_FILE_OUT_ \n";
  
  ofs << "constexpr int height = " << input.cols << ";" << "\n";
  ofs << "constexpr int width = " << input.rows << ";" << "\n";
  
  ofs << "constexpr unsigned int image_data[] { \n";
  
  for (int i = 0; i < input.cols; ++i)
    for (int j = 0; j < input.rows; ++j)
      ofs << (unsigned int)input.at<uchar>(j, i) << " , ";

  ofs << "}; \n";
  
  ofs << "\n";
  ofs << "#endif \n";
    
  ofs.close();
  
  return 0;
}
