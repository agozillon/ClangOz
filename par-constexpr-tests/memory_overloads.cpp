#include <dlfcn.h>
#include <stdio.h>
#include <stdint.h>
#include <execinfo.h>
#include <signal.h>
#include <stdlib.h>
#include <unistd.h>

// https://www.gnu.org/software/libc/manual/html_node/Backtraces.html 
// https://stackoverflow.com/questions/77005/how-to-automatically-generate-a-stacktrace-when-my-program-crashes/77336#77336
void print_backtrace() {
  void *array[10];
  size_t size = backtrace(array, 10);
  backtrace_symbols_fd(array, size, STDERR_FILENO);
}

// https://stackoverflow.com/questions/14884126/build-so-file-from-c-file-using-gcc-command-line
// clang++ -shared -fpic memory_overloads.cpp -ldl -o dbg_memory_impl.so

// https://stackoverflow.com/questions/262439/create-a-wrapper-function-for-malloc-and-free-in-c
// LD_PRELOAD=dbg_memory_impl.so ./exe

// http://www.jayconrod.com/posts/23

// Change to emit line numbers via macro
extern "C" void* malloc(size_t size)
{
    static void* (*real_malloc)(size_t) = NULL;
    if (!real_malloc)
        real_malloc = reinterpret_cast<void *(*)(size_t)>(dlsym(RTLD_NEXT, "malloc"));

    void *p = real_malloc(size);
    //fprintf(stderr, "malloc(%zu) = %p\n", size, p);
    return p;
}

extern "C" void free(void *p)
{
  //fprintf(stderr, "free has been invoked \n");
  if (!p) {
   print_backtrace();
   fprintf(stderr, "\n\n");
  }
  
  // can check if p is null, to detect a double free probably and emit a message
  // or cleaner callstack trace
  static void* (*real_free)(void*) = NULL;
  if (!real_free)
    real_free = reinterpret_cast<void *(*)(void *)>(dlsym(RTLD_NEXT, "free"));
  real_free(p);
}


/*
  has to be defined at the top of the file alongside the macro to test with this
*/
//extern "C" void* _my_malloc(size_t size, const unsigned long line = 0, 
//                            const char *file = "unspecified")
//{
//    fprintf(stderr, "malloc called in %s on line %lu\n", file, line);
//    static void* (*real_malloc)(size_t) = NULL;
//    if (!real_malloc)
//        real_malloc = reinterpret_cast<void *(*)(size_t)>(dlsym(RTLD_NEXT, "malloc"));

//    void *p = real_malloc(size);
//    fprintf(stderr, "malloc(%zu) = %p\n", size, p);
//    return p;
//}

//extern "C" void _my_free(void *p, const unsigned long line = 0, 
//                         const char *file = "unspecified")
//{
//    fprintf(stderr, "free called in %s on line %lu\n", file, line);
//    static void* (*real_free)(void*) = NULL;
//    if (!real_free)
//        real_free = reinterpret_cast<void *(*)(void *)>(dlsym(RTLD_NEXT, "free"));

//    real_free(p);
//}

//#define malloc(x) _my_malloc(x, __FILE__, __LINE__)
//#define free(x) _my_free(x, __FILE__, __LINE__)

// Add new/delete/etc.

/* 
 * Link-time interposition of malloc and free using the static
 * linker's (ld) "--wrap symbol" flag.
 * 
 * Compile the executable using "-Wl,--wrap,malloc -Wl,--wrap,free".
 * This tells the linker to resolve references to malloc as
 * __wrap_malloc, free as __wrap_free, __real_malloc as malloc, and
 * __real_free as free.
 */
/*void *__real_malloc(size_t size);*/
/*void __real_free(void *ptr);*/

/* 
 * __wrap_malloc - malloc wrapper function 
 */
/*void *__wrap_malloc(size_t size)*/
/*{*/
/*    void *ptr = __real_malloc(size);*/
/*    printf("malloc(%d) = %p\n", size, ptr);*/
/*    return ptr;*/
/*}*/

/* 
 * __wrap_free - free wrapper function 
 */
/*void __wrap_free(void *ptr)*/
/*{*/
/*    __real_free(ptr);*/
/*    printf("free(%p)\n", ptr);*/
/*}*/

/*int main()*/
/*{*/
/*    free(malloc(10));*/
/*    return 0;*/
/*}*/
