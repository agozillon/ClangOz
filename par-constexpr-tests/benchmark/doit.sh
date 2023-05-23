#!/bin/bash

function runprog {
  local basename=$1
  local nruns=$2
  local -n cores=$3
  local num_core_sizes=$4
  local -n sizes=$5  # array by name reference https://stackoverflow.com/a/26443029
  local num_sizes=$6
  local i j k delta total avg
  local CFLAGS="-O3 -std=c++20 -stdlib=libc++ -DCONSTEXPR_TRACK_TIME -fconstexpr-steps=4294967295 --no-warnings -I$CEST_INCLUDE"
  local PARFLAGS SZFLAG

pwd

  # echo $@

  echo "# Serial" | tee -a ${basename}.dat    # tee -a: append, do not overwrite
  for (( j = 0; j < num_sizes; j++ )); do
    total=0
    SZFLAG="-DSZ=${sizes[$j]}"

    for (( k = 0; k < nruns; k++ )); do
      delta="$($CLANGOZ_ROOT/bin/clang++ ${CFLAGS}               ${SZFLAG} ../../${basename}.cpp)"
      total=$(echo $total + $delta | bc)   # using bc for floating point
    done

    avg=$(echo "scale=5; $total / $nruns" | bc -l)  # 5 is the fp precision
    echo $avg ${sizes[$j]} | tee -a ${basename}.dat

  done

  for (( i = 0; i < num_core_sizes; i++ )); do
    PARFLAGS="-DCONSTEXPR_PARALLEL -fexperimental-constexpr-parallel -fconstexpr-parallel-partition-size=${cores[$i]}"
    echo "#" ${cores[$i]} "Threads" | tee -a ${basename}.dat

    for (( j = 0; j < num_sizes; j++ )); do
      total=0
      SZFLAG="-DSZ=${sizes[$j]}"

      for (( k = 0; k < nruns; k++ )); do
#        echo $CLANGOZ_ROOT/bin/clang++ ${CFLAGS} ${PARFLAGS} ${SZFLAG} ../../${basename}.cpp
        delta="$($CLANGOZ_ROOT/bin/clang++ ${CFLAGS} ${PARFLAGS} ${SZFLAG} ../../${basename}.cpp)"
        total=$(echo $total + $delta | bc)   # using bc for floating point
      done

      avg=$(echo "scale=5; $total / $nruns" | bc -l)  # 5 is the fp precision
      echo $avg ${sizes[$j]} | tee -a ${basename}.dat

    done
  done
}

NUM_RUNS=3 # For averaging, stddev etc.
CORE_COUNTS=(2 4 6 8 16)  # 16: Hyper-threading: 2 threads per core on i9-12900K (8 cores)
NUM_CORE_SIZES=2 # 5 # Could be made less than the size of CORE_COUNTS
MAND_SIZES=(32 64 128 256 512)
NUM_MAND_SIZES=3
BS_SIZES=(4 16 1024 4096 16384 65536)
NUM_BS_SIZES=3
NBODY_SIZES=(16 32 64 128 256)
NUM_NBODY_SIZES=2

TMPDIR=$(mktemp -d --tmpdir=mytemp)
cd $TMPDIR

#runprog cexpr_mandelbrot   $NUM_RUNS CORE_COUNTS $NUM_CORE_SIZES MAND_SIZES  $NUM_MAND_SIZES
runprog cexpr_blackscholes $NUM_RUNS CORE_COUNTS $NUM_CORE_SIZES BS_SIZES    $NUM_BS_SIZES
#runprog cexpr_nbody        $NUM_RUNS CORE_COUNTS $NUM_CORE_SIZES NBODY_SIZES $NUM_BS_SIZES

cd - > /dev/null
