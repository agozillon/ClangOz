
#ifndef _CEST_LOOP_WRAPPER
#define _CEST_LOOP_WRAPPER

/*
   These should just be id wrappers around variables etc. that also take 
   parameters that describe things about the algorithm we aim to constexpr 
   parallelize. Ideally these would be builtins.
  
  FIXME/NOTE: Currently there is a dependency in the compiler that requires 
  __BeginEndIteratorPair to always come before __IteratorLoopStep. This could be
  changed by registering all calls to __IteratorLoopStep and waiting until 
  __BeginEndIteratorPair is called before processing
*/
namespace cest::loop_wrapper {
  enum ReductionType { 
    Accumulate = 0,
  };
  
  enum OperatorType { 
    None = 0,
    PostInc = 1,
    PreInc = 2,
    PostDec = 3,
    PreDec = 4,
  };
  
  /*
     Takes the Argument Iter which is the variable we are trying to say has a 
     step size of StepSize.
  */
  template <typename T>
  constexpr void __IteratorLoopStep(T Iter, int StepSize) {}
  
    /*
     Used by the compiler to calculate the loops extent and helps it work out
     how to partition the loop across cores by allowing the calculation of 
     begining and end segments of the partitions. 
     
     Takes the Argument Begin and End, begin being the beginning of the loop
     and end being the end of the loop. e.g. _first != _last when both are 
     iterators and the != is the end condition of the loop.
  */
  template <typename T, typename T2>
  constexpr void __BeginEndIteratorPair(T Begin, T2 End) {}


  /*
    Indicates that a variable needs to be reduced into a single value or single 
    set of values (e.g. an array) at the end of a parallelized loop. This is 
    usually the case when some value that's shared across the parititons is used
    that needs to be combined on completions. An example of this is the count
    and count_if algorithms.
    
    Var is the variable that the reduction should be performed on, RedTy is the
    type of reduction the compiler should perform and OpTy is the operator if 
    there is any that should be used when reducing.
    
    You can wrap it around the variable inside the loop or outside of it, but it
    will come at a cost if you wrap it around something inside the loop as it'll
    be another layer of calculations that the compiler needs to do (it'll have 
    to "execute" the function every loop iteration), even if it is essenitally a
    NoOp.
  */
  template <typename T>
  constexpr void __ReduceVariable(T Var, ReductionType RedTy, 
                                  OperatorType OpTy = OperatorType::None) {}


}

#endif // _CEST_LOOP_WRAPPER
