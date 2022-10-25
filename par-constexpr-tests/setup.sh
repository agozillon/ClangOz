export CXX=~/Documents/Clang-LLVM/build/bin/clang++
export CC=~/Documents/Clang-LLVM/build/bin/clang
export CLANG_OZ=~/Documents/Clang-LLVM/build
export CLANGOZ=~/Documents/Clang-LLVM/build
export CEST_INCLUDE=~/Documents/cest/include
export PATH=$PATH:/home/gozillon/Documents/cest:/home/gozillon/Documents/
export PATH=$PATH:/home/gozillon/Documents/Clang-LLVM/libcxx/include
export PATH=$PATH:/home/gozillon/Documents/Clang-LLVM/libcxx/lib
export PATH=$PATH:/home/gozillon/Documents/Clang-LLVM/build/lib
export PATH=$PATH:/home/gozillon/Documents/Clang-LLVM/build/include
export MOTORSYCL_INCLUDE=~/Documents/cpp-std-parallel/sycl/include
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/gozillon/Documents/Clang-LLVM/libcxx/lib:/home/gozillon/Documents/Clang-LLVM/build/lib:/home/gozillon/Documents/Clang-LLVM/build/lib/x86_64-unknown-linux-gnu
# These are for the SYCL runtime, but are not neccessary for compilation regardless of runtime use or not provided you give the right pre-proccessor flags
# however, if you want to use the runtime SYCL implementation then they're required as compiling the parallel STL! 
export PSTL_INCLUDE=~/Documents/Clang-LLVM/pstl/include
export PSTL_INTERINAL_INCLUDE=~/Documents/Clang-LLVM/pstl/include/pstl/internal
