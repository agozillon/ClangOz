#include "cest/shared_ptr.hpp"


constexpr int do_something() {

  // using a shared_ptr in a lambda capture will ice the compiler for some reason
  // it appears to be related to having a base class. 
  /*cest::shared_ptr<int> data{*//*};*/

   int*temp = new int{123};

//  [data]() {  //no buenos, ICE'd compiler
//    data.use_count();
//  };  

  [=]() mutable {
    *temp++;
  };
  
  delete temp;
  return 0;
}

int main() {
  constexpr auto someval = do_something();

  return 0;
}
