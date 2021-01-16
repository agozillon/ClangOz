
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
    PartitionedOrderedAssign = 1,
    OrderedAssign = 2
  };

  enum OperatorType { 
    OperatorNone = 0,
    PostInc = 1,
    PreInc = 2,
    PostDec = 3,
    PreDec = 4,
    Assign = 5,
  };

  enum EqualityType {
    EqualityNone = 0,
    LT = 1,   // <
    GT = 2,   // >
    LTEq = 3, // <=
    GTEq = 4, // >=
    NEq = 5,  // !=
    Eq = 6,   // ==
  };

  /*
    Takes the Argument Iter which is the variable and offsets it in relation to
    the last invoked __BeginEndIteratorPair within the function body, this only
    really offsets based on the starting point of the iterator pair rather than
    the end point.

    Note: The parameters are references to simplify the Clang AST that needs 
    walked to get the information we want, one example is that if a user for 
    some reason uses an inline constructor to create a parameter to one of the 
    std:: functions we'll avoid having to deal with a constructor node, which
    can be difficult to deal with (it can have multiple parameters and we'd 
    have to diagnose which one is correct).
  */
  template <typename T>
  constexpr void __IteratorLoopStep(T& StartIter, int StepSize, 
                                    OperatorType OpTy = 
                                    OperatorType::PreInc, 
                                    const T& BoundIter=T{}){}
  
  /*
     Used by the compiler to calculate the loops extent and helps it work out
     how to partition the loop across cores by allowing the calculation of 
     begining and end segments of the partitions. 
     
     Takes the Argument Begin and End, begin being the beginning of the loop
     and end being the end of the loop. e.g. _first != _last when both are 
     iterators and the != is the end condition of the loop.
  
    Note: The parameters are references to simplify the Clang AST that needs 
    walked to get the information we want, one example is that if a user for 
    some reason uses an inline constructor to create a parameter to one of the 
    std:: functions we'll avoid having to deal with a constructor node, which
    can be difficult to deal with (it can have multiple parameters and we'd 
    have to diagnose which one is correct).
  */
  template <typename T, typename T2>
  constexpr void __BeginEndIteratorPair(T& Begin, T2& End){}

  /*
    Asks the compiler to create a copy of the variable per thread which can be 
    modified seperately, on it's own there's no semantics for unifying the data.
    
    A lot of the other wrappers in here will create thread local copies by 
    default. For example, IteratorLoopStep will create local copies of the 
    iterator set at certain offsets for each thread, in such cases there is no
    requirement for this wrapper.
  */
  template <typename T>
  constexpr void __ThreadLocalCopy(T Var){}
  
  /*
    Inidicates that a variable should be unmutated and remain unchanged at the 
    end of the loop body. This largelly means we will not update it's data
    at the end of the threads completion.
  */
  template <typename T>
  constexpr void __ImmutableVariable(T Var){}
  
  /*
    This will aquire a lock stopping the segments until the 
    __ThreadUnlock call from being run in parallel. It's incorrect to call this
    multiple times in a row without invoking a __ThreadUnlock call, it will 
    cause a compiler assertion.
  */
  constexpr bool __ThreadLock(){ return true; }
  
  /*
    Releases the lock that __ThreadLock has aquired.
  */
  constexpr bool __ThreadUnlock(){ return true; }

  /*
    Not really wrappers that affect anything other than taking some time stamps
    can only track one stamp at a time
    
    Should only really be used out with a constexpr parallel section.
  */
  constexpr bool __GetTimeStampStart(){ return true; }

  /*
    Not really wrappers that affect anything other than taking some time stamps
    can only track one stamp at a time.
    
    Should only really be used out with a constexpr parallel section.
  */
  constexpr bool __GetTimeStampEnd(){ return true; }
  
  /*
    Asks the compiler to print a time stamp at the current point based on the
    currently recorded Start and End.
    
    Should only really be used out with a constexpr parallel section.
  */
  constexpr bool __PrintTimeStamp(){ return true; }
  
  /*
    Equivelant of __IteratorLoopStep/__BeginEndIteratorPair for normal loops 
    that make use of integers indexes rather than iterators
  */
  template <typename T, typename T2>
  constexpr void __PartitionUsingIndex(T LHS, T2 RHS, 
                                       EqualityType EqTy = 
                                         EqualityType::EqualityNone){}
  
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
                                  OperatorType OpTy = 
                                    OperatorType::OperatorNone){}


}

#endif // _CEST_LOOP_WRAPPER
