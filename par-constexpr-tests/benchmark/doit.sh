#!/bin/bash

CFLAGS="-O3 -std=c++20 -stdlib=libc++ -DCONSTEXPR_TRACK_TIME -fconstexpr-steps=4294967295 --no-warnings -I$CEST_INCLUDE"

function run_program {
  local base_filename=$1
  local name=$2[@]
  local sizes=("${!name}")
  local n=$3

  echo $@
  for (( j = 0; j < n; j++ )); do
    echo "${sizes[$j]}"
  done

  TIME_DIFF="$($CLANGOZ_ROOT/bin/clang++ ${CFLAGS} -DSZ=32 -DMAXITERS=128 ../../${base_filename}.cpp)"
  echo $TIME_DIFF
}

MAND_SIZES=(32 64 128 256 512)
NUM_SIZES=3

TMPDIR=$(mktemp -d --tmpdir=mytemp)
cd $TMPDIR
run_program cexpr_mandelbrot MAND_SIZES ${NUM_SIZES}
# run_program cexpr_mandelbrot "${MAND_SIZES[@]}" ${NUM_SIZES}
cd - > /dev/null
