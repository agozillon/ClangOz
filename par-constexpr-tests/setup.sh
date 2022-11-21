export CXX=$CLANGOZ_ROOT/bin/clang++
export CC=$CLANGOZ_ROOT/bin/clang
export LD_LIBRARY_PATH=$CLANGOZ_ROOT/lib:$CLANGOZ_ROOT/lib/x86_64-unknown-linux-gnu:$LD_LIBRARY_PATH

# These are for the SYCL runtime, but are not neccessary for compilation
# regardless of runtime use or not provided you give the right pre-proccessor
# flags however, if you want to use the runtime SYCL implementation then
# they're required as compiling the parallel STL!

#export PSTL_INCLUDE=$LLVM_CLANG_SRC_DIR/pstl/include
#export PSTL_INTERNAL_INCLUDE=$LLVM_CLANG_SRC_DIR/pstl/include/pstl/internal
