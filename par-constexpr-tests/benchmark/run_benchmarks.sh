#!/bin/bash

# 3) check the step limits in the compiler and make sure it works without a race condition

# NOTE: you can always ignore the first Print Time Stamp in the output, it 
# appears to be an unfortunate side affect of initilization or inclusion...

################################################################################
#                                 Blackscholes
################################################################################

# Blackscholes can have the number of runs varied and the data set increased in 
# size. The number of runs doesn't alter the results, it simply uses the same 
# data set to calculate the same result. Verification of the results is done 
# inside the program. Runs of the max size can take up to 2-3 minutes.

mkdir blackscholes_results
pushd blackscholes_results

# NOTE: Can I concatanate all the results into 1 .csv file? To do this I need to 
# work out how to cut out the first "fake" print statement, a very cheap hack is
# to just count that we've entered the if statement more than once before 
# printing. Might not work though some tests seem to have more than 1 warmup 
# pass...

# NOTE: It may be possible to do the constexpr steps similarly to the timer, it
# depends on if the steps are carried over to the next call location, otherwise
# it becomes a little bit difficult to get an accurate number of steps. Needs 
# some looking into.

function execute_blackscholes_lin {
  echo "Executing Blackscholes: Linear, -DBLACKSCHOLES_$1, -DNRUN_$2"

  time $CLANGOZ/bin/clang++ -DBLACKSCHOLES_$1 -DNRUN_$2 -fconstexpr-steps=4294967295 -w -I$CEST_INCLUDE -std=c++2a -stdlib=libc++ ../cexpr_blackscholes.cpp -o lin_blackscholes$1_run$2.o &> lin_blackscholes$1_run$2_result.txt
}

execute_blackscholes_lin 4 1
execute_blackscholes_lin 16 1
execute_blackscholes_lin 1K 1
execute_blackscholes_lin 4K 1
execute_blackscholes_lin 16K 1
execute_blackscholes_lin 64K 1

execute_blackscholes_lin 4 2
execute_blackscholes_lin 16 2
execute_blackscholes_lin 1K 2
execute_blackscholes_lin 4K 2
execute_blackscholes_lin 16K 2
execute_blackscholes_lin 64K 2

execute_blackscholes_lin 4 3
execute_blackscholes_lin 16 3
execute_blackscholes_lin 1K 3
execute_blackscholes_lin 4K 3
execute_blackscholes_lin 16K 3
execute_blackscholes_lin 64K 3

execute_blackscholes_lin 4 4
execute_blackscholes_lin 16 4
execute_blackscholes_lin 1K 4
execute_blackscholes_lin 4K 4
execute_blackscholes_lin 16K 4
execute_blackscholes_lin 64K 4


function execute_blackscholes_par {
  echo "Executing Blackscholes: Parallel, -DBLACKSCHOLES_$1, -DNRUN_$2, Number of Cores $3"

  time $CLANGOZ/bin/clang++ -DCONSTEXPR_PARALLEL -DBLACKSCHOLES_$1 -DNRUN_$2 -fconstexpr-steps=4294967295 -w -fconstexpr-parallel-partition-size=$3 -fexperimental-constexpr-parallel -I$CEST_INCLUDE -std=c++2a -stdlib=libc++ ../cexpr_blackscholes.cpp -o par_blackscholes$1_run$2_cores$3.o &> par_blackscholes$1_run$2_cores$3_result.txt

}

execute_blackscholes_par 4 1 2
execute_blackscholes_par 16 1 2
execute_blackscholes_par 1K 1 2
execute_blackscholes_par 4K 1 2
execute_blackscholes_par 16K 1 2
execute_blackscholes_par 64K 1 2

execute_blackscholes_par 4 2 2
execute_blackscholes_par 16 2 2
execute_blackscholes_par 1K 2 2
execute_blackscholes_par 4K 2 2
execute_blackscholes_par 16K 2 2
execute_blackscholes_par 64K 2 2

execute_blackscholes_par 4 3 2
execute_blackscholes_par 16 3 2
execute_blackscholes_par 1K 3 2
execute_blackscholes_par 4K 3 2
execute_blackscholes_par 16K 3 2
execute_blackscholes_par 64K 3 2

execute_blackscholes_par 4 4 2
execute_blackscholes_par 16 4 2
execute_blackscholes_par 1K 4 2
execute_blackscholes_par 4K 4 2
execute_blackscholes_par 16K 4 2
execute_blackscholes_par 64K 4 2

execute_blackscholes_par 4 1 3
execute_blackscholes_par 16 1 3
execute_blackscholes_par 1K 1 3
execute_blackscholes_par 4K 1 3
execute_blackscholes_par 16K 1 3
execute_blackscholes_par 64K 1 3

execute_blackscholes_par 4 2 3
execute_blackscholes_par 16 2 3
execute_blackscholes_par 1K 2 3
execute_blackscholes_par 4K 2 3
execute_blackscholes_par 16K 2 3
execute_blackscholes_par 64K 2 3

execute_blackscholes_par 4 3 3
execute_blackscholes_par 16 3 3
execute_blackscholes_par 1K 3 3
execute_blackscholes_par 4K 3 3
execute_blackscholes_par 16K 3 3
execute_blackscholes_par 64K 3 3

execute_blackscholes_par 4 4 3
execute_blackscholes_par 16 4 3
execute_blackscholes_par 1K 4 3
execute_blackscholes_par 4K 4 3
execute_blackscholes_par 16K 4 3
execute_blackscholes_par 64K 4 3

execute_blackscholes_par 4 1 4
execute_blackscholes_par 16 1 4
execute_blackscholes_par 1K 1 4
execute_blackscholes_par 4K 1 4
execute_blackscholes_par 16K 1 4
execute_blackscholes_par 64K 1 4

execute_blackscholes_par 4 2 4
execute_blackscholes_par 16 2 4
execute_blackscholes_par 1K 2 4
execute_blackscholes_par 4K 2 4
execute_blackscholes_par 16K 2 4
execute_blackscholes_par 64K 2 4

execute_blackscholes_par 4 3 4
execute_blackscholes_par 16 3 4
execute_blackscholes_par 1K 3 4
execute_blackscholes_par 4K 3 4
execute_blackscholes_par 16K 3 4
execute_blackscholes_par 64K 3 4

execute_blackscholes_par 4 4 4
execute_blackscholes_par 16 4 4
execute_blackscholes_par 1K 4 4
execute_blackscholes_par 4K 4 4
execute_blackscholes_par 16K 4 4
execute_blackscholes_par 64K 4 4

popd

################################################################################
#                                 Mandelbrot
################################################################################

mkdir mandelbrot_results
pushd mandelbrot_results

function execute_mandelbrot_lin {
  echo "Executing mandelbrot: Linear, -DHXW_$1, -DMAXITERS_$2"
  time $CLANGOZ/bin/clang++ -DHXW_$1 -DMAXITERS_$2 -fconstexpr-steps=4294967295 -w -I$CEST_INCLUDE -std=c++2a -stdlib=libc++ ../cexpr_mandelbrot.cpp -o lin_mandelbrot_hxw$1_maxiters$2.o &> lin_mandelbrot_hxw$1_maxiters$2_results.txt
}

function execute_mandelbrot_par {
  echo "Executing mandelbrot: Parallel, -DHXW_$1, -DMAXITERS_$2, Number of Cores $3"
  time $CLANGOZ/bin/clang++ -DCONSTEXPR_PARALLEL -DHXW_$1 -DMAXITERS_$2 -fconstexpr-steps=4294967295 -w -fconstexpr-parallel-partition-size=$3 -I$CEST_INCLUDE -std=c++2a -stdlib=libc++ ../cexpr_mandelbrot.cpp -o par_mandelbrot_hxw$1_maxiters$2_cores$3.o &> par_mandelbrot_hxw$1_maxiters$2_cores$3_results.txt
}

execute_mandelbrot_lin 32 32
execute_mandelbrot_lin 64 32
execute_mandelbrot_lin 128 32
execute_mandelbrot_lin 256 32
execute_mandelbrot_lin 512 32

execute_mandelbrot_lin 32 64
execute_mandelbrot_lin 64 64
execute_mandelbrot_lin 128 64
execute_mandelbrot_lin 256 64
execute_mandelbrot_lin 512 64

execute_mandelbrot_lin 32 128
execute_mandelbrot_lin 64 128
execute_mandelbrot_lin 128 128
execute_mandelbrot_lin 256 128
execute_mandelbrot_lin 512 128

execute_mandelbrot_lin 32 256
execute_mandelbrot_lin 64 256
execute_mandelbrot_lin 128 256
execute_mandelbrot_lin 256 256
execute_mandelbrot_lin 512 256

execute_mandelbrot_lin 32 512
execute_mandelbrot_lin 64 512
execute_mandelbrot_lin 128 512
execute_mandelbrot_lin 256 512
execute_mandelbrot_lin 512 512


execute_mandelbrot_par 32 32 2
execute_mandelbrot_par 64 32 2
execute_mandelbrot_par 128 32 2
execute_mandelbrot_par 256 32 2
execute_mandelbrot_par 512 32 2

execute_mandelbrot_par 32 64 2
execute_mandelbrot_par 64 64 2
execute_mandelbrot_par 128 64 2
execute_mandelbrot_par 256 64 2
execute_mandelbrot_par 512 64 2

execute_mandelbrot_par 32 128 2
execute_mandelbrot_par 64 128 2
execute_mandelbrot_par 128 128 2
execute_mandelbrot_par 256 128 2
execute_mandelbrot_par 512 128 2

execute_mandelbrot_par 32 256 2
execute_mandelbrot_par 64 256 2
execute_mandelbrot_par 128 256 2
execute_mandelbrot_par 256 256 2
execute_mandelbrot_par 512 256 2

execute_mandelbrot_par 32 512 2
execute_mandelbrot_par 64 512 2
execute_mandelbrot_par 128 512 2
execute_mandelbrot_par 256 512 2
execute_mandelbrot_par 512 512 2

execute_mandelbrot_par 32 32 3
execute_mandelbrot_par 64 32 3
execute_mandelbrot_par 128 32 3
execute_mandelbrot_par 256 32 3
execute_mandelbrot_par 512 32 3

execute_mandelbrot_par 32 64 3
execute_mandelbrot_par 64 64 3
execute_mandelbrot_par 128 64 3
execute_mandelbrot_par 256 64 3
execute_mandelbrot_par 512 64 3

execute_mandelbrot_par 32 128 3
execute_mandelbrot_par 64 128 3
execute_mandelbrot_par 128 128 3
execute_mandelbrot_par 256 128 3
execute_mandelbrot_par 512 128 3

execute_mandelbrot_par 32 256 3
execute_mandelbrot_par 64 256 3
execute_mandelbrot_par 128 256 3
execute_mandelbrot_par 256 256 3
execute_mandelbrot_par 512 256 3

execute_mandelbrot_par 32 512 3
execute_mandelbrot_par 64 512 3
execute_mandelbrot_par 128 512 3
execute_mandelbrot_par 256 512 3
execute_mandelbrot_par 512 512 3

execute_mandelbrot_par 32 32 4
execute_mandelbrot_par 64 32 4
execute_mandelbrot_par 128 32 4
execute_mandelbrot_par 256 32 4
execute_mandelbrot_par 512 32 4

execute_mandelbrot_par 32 64 4
execute_mandelbrot_par 64 64 4
execute_mandelbrot_par 128 64 4
execute_mandelbrot_par 256 64 4
execute_mandelbrot_par 512 64 4

execute_mandelbrot_par 32 128 4
execute_mandelbrot_par 64 128 4
execute_mandelbrot_par 128 128 4
execute_mandelbrot_par 256 128 4
execute_mandelbrot_par 512 128 4

execute_mandelbrot_par 32 256 4
execute_mandelbrot_par 64 256 4
execute_mandelbrot_par 128 256 4
execute_mandelbrot_par 256 256 4
execute_mandelbrot_par 512 256 4

execute_mandelbrot_par 32 512 4
execute_mandelbrot_par 64 512 4
execute_mandelbrot_par 128 512 4
execute_mandelbrot_par 256 512 4
execute_mandelbrot_par 512 512 4

popd

################################################################################
#                                 Swaptions
################################################################################

mkdir swaptions_results
pushd swaptions_results

function execute_swaptions_lin {
  echo "Executing swaptions: Linear, -DNTRIALS_$1, -DNSWAPTIONS_$2"
  time $CLANGOZ/bin/clang++ -DNTRIALS_$1 -DNSWAPTIONS_$2 -fconstexpr-steps=4294967295 -w -I$CEST_INCLUDE -std=c++2a -stdlib=libc++ ../cexpr_swaptions.cpp -o lin_swaptions_ntrials$1_nswaptions$2.o &> lin_swaptions_ntrials$1_nswaptions$2_results.txt
}

function execute_swaptions_par {
  echo "Executing swaptions: Parallel, -DNTRIALS_$1, -DNSWAPTIONS_$2, Number of Cores $3"
  time $CLANGOZ/bin/clang++ -DCONSTEXPR_PARALLEL -DNTRIALS_$1 -DNSWAPTIONS_$2 -fconstexpr-steps=4294967295 -w -fconstexpr-parallel-partition-size=$3 -I$CEST_INCLUDE -std=c++2a -stdlib=libc++ ../cexpr_swaptions.cpp -o par_swaptions_ntrials$1_nswaptions$2_cores$3.o &> par_swaptions_ntrials$1_nswaptions$2_cores$3_results.txt
}

execute_swaptions_lin 5120 4
execute_swaptions_lin 10240 4
execute_swaptions_lin 20480 4
execute_swaptions_lin 40960 4
execute_swaptions_lin 81920 4

execute_swaptions_lin 5120 8
execute_swaptions_lin 10240 8
execute_swaptions_lin 20480 8
execute_swaptions_lin 40960 8
execute_swaptions_lin 81920 8

execute_swaptions_lin 5120 16
execute_swaptions_lin 10240 16
execute_swaptions_lin 20480 16
execute_swaptions_lin 40960 16
execute_swaptions_lin 81920 16

execute_swaptions_lin 5120 32
execute_swaptions_lin 10240 32
execute_swaptions_lin 20480 32
execute_swaptions_lin 40960 32
execute_swaptions_lin 81920 32

execute_swaptions_lin 5120 64
execute_swaptions_lin 10240 64
execute_swaptions_lin 20480 64
execute_swaptions_lin 40960 64
execute_swaptions_lin 81920 64

execute_swaptions_lin 5120 128
execute_swaptions_lin 10240 128
execute_swaptions_lin 20480 128
execute_swaptions_lin 40960 128
execute_swaptions_lin 81920 128

execute_swaptions_lin 5120 256
execute_swaptions_lin 10240 256
execute_swaptions_lin 20480 256
execute_swaptions_lin 40960 256
execute_swaptions_lin 81920 256

execute_swaptions_par 5120 4
execute_swaptions_par 10240 4
execute_swaptions_par 20480 4
execute_swaptions_par 40960 4
execute_swaptions_par 81920 4

execute_swaptions_par 5120 8 2
execute_swaptions_par 10240 8 2
execute_swaptions_par 20480 8 2
execute_swaptions_par 40960 8 2
execute_swaptions_par 81920 8 2

execute_swaptions_par 5120 16 2
execute_swaptions_par 10240 16 2
execute_swaptions_par 20480 16 2
execute_swaptions_par 40960 16 2
execute_swaptions_par 81920 16 2

execute_swaptions_par 5120 32 2
execute_swaptions_par 10240 32 2
execute_swaptions_par 20480 32 2
execute_swaptions_par 40960 32 2
execute_swaptions_par 81920 32 2

execute_swaptions_par 5120 64 2
execute_swaptions_par 10240 64 2
execute_swaptions_par 20480 64 2
execute_swaptions_par 40960 64 2
execute_swaptions_par 81920 64 2

execute_swaptions_par 5120 128 2
execute_swaptions_par 10240 128 2
execute_swaptions_par 20480 128 2
execute_swaptions_par 40960 128 2
execute_swaptions_par 81920 128 2

execute_swaptions_par 5120 256 2
execute_swaptions_par 10240 256 2
execute_swaptions_par 20480 256 2
execute_swaptions_par 40960 256 2
execute_swaptions_par 81920 256 2

execute_swaptions_par 5120 8 3
execute_swaptions_par 10240 8 3
execute_swaptions_par 20480 8 3
execute_swaptions_par 40960 8 3
execute_swaptions_par 81920 8 3

execute_swaptions_par 5120 16 3
execute_swaptions_par 10240 16 3
execute_swaptions_par 20480 16 3
execute_swaptions_par 40960 16 3
execute_swaptions_par 81920 16 3

execute_swaptions_par 5120 32 3
execute_swaptions_par 10240 32 3
execute_swaptions_par 20480 32 3
execute_swaptions_par 40960 32 3
execute_swaptions_par 81920 32 3

execute_swaptions_par 5120 64 3
execute_swaptions_par 10240 64 3
execute_swaptions_par 20480 64 3
execute_swaptions_par 40960 64 3
execute_swaptions_par 81920 64 3

execute_swaptions_par 5120 128 3
execute_swaptions_par 10240 128 3
execute_swaptions_par 20480 128 3
execute_swaptions_par 40960 128 3
execute_swaptions_par 81920 128 3

execute_swaptions_par 5120 256 3
execute_swaptions_par 10240 256 3
execute_swaptions_par 20480 256 3
execute_swaptions_par 40960 256 3
execute_swaptions_par 81920 256 3

execute_swaptions_par 5120 8 4
execute_swaptions_par 10240 8 4
execute_swaptions_par 20480 8 4
execute_swaptions_par 40960 8 4
execute_swaptions_par 81920 8 4

execute_swaptions_par 5120 16 4
execute_swaptions_par 10240 16 4
execute_swaptions_par 20480 16 4
execute_swaptions_par 40960 16 4
execute_swaptions_par 81920 16 4

execute_swaptions_par 5120 32 4
execute_swaptions_par 10240 32 4
execute_swaptions_par 20480 32 4
execute_swaptions_par 40960 32 4
execute_swaptions_par 81920 32 4

execute_swaptions_par 5120 64 4
execute_swaptions_par 10240 64 4
execute_swaptions_par 20480 64 4
execute_swaptions_par 40960 64 4
execute_swaptions_par 81920 64 4

execute_swaptions_par 5120 128 4
execute_swaptions_par 10240 128 4
execute_swaptions_par 20480 128 4
execute_swaptions_par 40960 128 4
execute_swaptions_par 81920 128 4

execute_swaptions_par 5120 256 4
execute_swaptions_par 10240 256 4
execute_swaptions_par 20480 256 4
execute_swaptions_par 40960 256 4
execute_swaptions_par 81920 256 4

popd

################################################################################
#                                 nbody
################################################################################

mkdir nbody_results
pushd nbody_results

# NITERS_* 62500, 125000, 250000, 500000, 1000000;
# NBODIES_* 5,10,15,20,25

function execute_nbody_lin {
  echo "Executing nbody: Linear, -DNITERS_$1, -DNBODIES_$2"
  time $CLANGOZ/bin/clang++ -DNITERS_$1 -DNBODIES_$2 -fconstexpr-steps=4294967295 -w -I$CEST_INCLUDE -std=c++2a -stdlib=libc++ ../cexpr_nbody.cpp -o lin_nbody_niters$1_nbodies$2.o &> lin_nbody_niters$1_nbodies$2_results.txt
}

function execute_nbody_par {
  echo "Executing nbody: Parallel, -DNITERS_$1, -DNBODIES_$2, Number of Cores $3"
  time $CLANGOZ/bin/clang++ -DCONSTEXPR_PARALLEL -DNITERS_$1 -DNBODIES_$2 -fconstexpr-steps=4294967295 -w -fconstexpr-parallel-partition-size=$3 -I$CEST_INCLUDE -std=c++2a -stdlib=libc++ ../cexpr_nbody.cpp -o par_nbody_niters$1_nbodies$2_cores$3.o &> par_nbody_niters$1_nbodies$2_cores$3_results.txt
}

execute_nbody_lin 62500 5
execute_nbody_lin 125000 5
execute_nbody_lin 250000 5
execute_nbody_lin 500000 5
execute_nbody_lin 1000000 5

execute_nbody_lin 62500 10
execute_nbody_lin 125000 10
execute_nbody_lin 250000 10
execute_nbody_lin 500000 10
execute_nbody_lin 1000000 10

execute_nbody_lin 62500 15
execute_nbody_lin 125000 15
execute_nbody_lin 250000 15
execute_nbody_lin 500000 15
execute_nbody_lin 1000000 15

execute_nbody_lin 62500 20
execute_nbody_lin 125000 20
execute_nbody_lin 250000 20
execute_nbody_lin 500000 20
execute_nbody_lin 1000000 20

execute_nbody_lin 62500 25
execute_nbody_lin 125000 25
execute_nbody_lin 250000 25
execute_nbody_lin 500000 25
execute_nbody_lin 1000000 25

execute_nbody_par 62500 5 2
execute_nbody_par 125000 5 2
execute_nbody_par 250000 5 2
execute_nbody_par 500000 5 2
execute_nbody_par 1000000 5 2

execute_nbody_par 62500 10 2
execute_nbody_par 125000 10 2
execute_nbody_par 250000 10 2
execute_nbody_par 500000 10 2
execute_nbody_par 1000000 10 2

execute_nbody_par 62500 15 2
execute_nbody_par 125000 15 2
execute_nbody_par 250000 15 2
execute_nbody_par 500000 15 2
execute_nbody_par 1000000 15 2

execute_nbody_par 62500 20 2
execute_nbody_par 125000 20 2
execute_nbody_par 250000 20 2
execute_nbody_par 500000 20 2
execute_nbody_par 1000000 20 2

execute_nbody_par 62500 25 2
execute_nbody_par 125000 25 2
execute_nbody_par 250000 25 2
execute_nbody_par 500000 25 2
execute_nbody_par 1000000 25 2

execute_nbody_par 62500 5 3
execute_nbody_par 125000 5 3
execute_nbody_par 250000 5 3
execute_nbody_par 500000 5 3
execute_nbody_par 1000000 5 3

execute_nbody_par 62500 10 3
execute_nbody_par 125000 10 3
execute_nbody_par 250000 10 3
execute_nbody_par 500000 10 3
execute_nbody_par 1000000 10 3

execute_nbody_par 62500 15 3
execute_nbody_par 125000 15 3
execute_nbody_par 250000 15 3
execute_nbody_par 500000 15 3
execute_nbody_par 1000000 15 3

execute_nbody_par 62500 20 3
execute_nbody_par 125000 20 3
execute_nbody_par 250000 20 3
execute_nbody_par 500000 20 3
execute_nbody_par 1000000 20 3

execute_nbody_par 62500 25 3
execute_nbody_par 125000 25 3
execute_nbody_par 250000 25 3
execute_nbody_par 500000 25 3
execute_nbody_par 1000000 25 3

execute_nbody_par 62500 5 4
execute_nbody_par 125000 5 4
execute_nbody_par 250000 5 4
execute_nbody_par 500000 5 4
execute_nbody_par 1000000 5 4

execute_nbody_par 62500 10 4
execute_nbody_par 125000 10 4
execute_nbody_par 250000 10 4
execute_nbody_par 500000 10 4
execute_nbody_par 1000000 10 4

execute_nbody_par 62500 15 4
execute_nbody_par 125000 15 4
execute_nbody_par 250000 15 4
execute_nbody_par 500000 15 4
execute_nbody_par 1000000 15 4

execute_nbody_par 62500 20 4
execute_nbody_par 125000 20 4
execute_nbody_par 250000 20 4
execute_nbody_par 500000 20 4
execute_nbody_par 1000000 20 4

execute_nbody_par 62500 25 4
execute_nbody_par 125000 25 4
execute_nbody_par 250000 25 4
execute_nbody_par 500000 25 4
execute_nbody_par 1000000 25 4

popd

