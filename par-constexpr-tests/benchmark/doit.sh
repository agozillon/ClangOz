#!/bin/bash

CFLAGS="-O3 -std=c++20 -stdlib=libc++ -DCONSTEXPR_TRACK_TIME -fconstexpr-steps=4294967295 --no-warnings -I$CEST_INCLUDE"

function runprog {
  local basename=$1
  local nruns=$2
  local name3=$3[@]
  local sizes=("${!name3}")
  local n=$4
  local name5=$5[@]
  local cores=("${!name5}")
  local num_core_sizes=$6
  local i j k total avg

  echo $@
  for (( i = 0; i < num_core_sizes; i++ )); do
    for (( j = 0; j < n; j++ )); do
      total=0
      for (( k = 0; k < nruns; k++ )); do
        timetest=0.2
        total=$(echo $total + $timetest | bc)   # using bc for floating point
        echo ${cores[$i]} ${sizes[$j]} $k
      done
      avg=$(echo "scale=5; $total / $nruns" | bc -l)  # 5 is the fp precision
      echo total is $total and average is $avg
    done
  done

  TIME_DIFF="$($CLANGOZ_ROOT/bin/clang++ ${CFLAGS} -DSZ=32 ../../${basename}.cpp)"
  echo $TIME_DIFF
}

NUM_RUNS=4 # For averaging, stddev etc.
CORE_COUNTS=(2 4 6 8)
NUM_CORE_SIZES=2 # 4 # Could be made less than the size of CORE_COUNTS
MAND_SIZES=(32 64 128 256 512)
NUM_MAND_SIZES=3

TMPDIR=$(mktemp -d --tmpdir=mytemp)
cd $TMPDIR
runprog cexpr_mandelbrot $NUM_RUNS MAND_SIZES $NUM_MAND_SIZES CORE_COUNTS $NUM_CORE_SIZES
# run_program cexpr_mandelbrot "${MAND_SIZES[@]}" ${NUM_SIZES}
cd - > /dev/null
