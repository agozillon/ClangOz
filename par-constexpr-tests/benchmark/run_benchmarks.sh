#!/bin/bash

CORE_COUNTS=(2 4 6 8)
NUM_CORE_SIZES=2 # 4 # Could be made less than the size of CORE_COUNTS

num_sizes=4
bs_sizes=(4 16 1K 4K 16K 64K)
num_bs_sizes=2 #$num_sizes # Could be made less than the size of bs_sizes.
#mand_sizes=(25 50 75 100 125)
mand_sizes=(32 64 128 256 512)
num_mand_sizes=2 # 5 # $num_sizes
swap_sizes=(2 4 6 8 10)
num_swap_sizes=2 #2 #$num_sizes
nbody_sizes=(16 32 64 128 256)
num_nbody_sizes=2 #$num_sizes
edge_sizes=(64 128 256 512)
num_edge_sizes=2 #$num_sizes

if [[ -z "${CEST_INCLUDE}" ]]; then
  printf "%s%s\n" "error: Please ensure CEST_INCLUDE is defined, " \
         "and pointing at your install of https://github.com/SCT4SP/cest"
  exit -1
fi

if [ ! -d "$CEST_INCLUDE" ]; then
  echo "error: The directory named in CEST_INCLUDE ($CEST_INCLUDE) doesn't exist."
  exit -1
fi

if [[ "$MOTORSYCL_INCLUDE" == *"motorsycl"* ]]; then
  echo "error: If \$MOTORSYCL_INCLUDE id defined, it must not point to the "
  echo "MotorSYCL repo. Otherwise, when running the SYCL edge detection "
  echo "benchmark, it will fail. Instead, set \$MOTORSYCL_INCLUDE to the "
  echo "sycl/include subdirectory in the par-constexpr-sycl branch of "
  echo "https://github.com/pkeir/cpp-std-parallel."
  exit -2
fi

#* Look into Speedup graph:

#  http://selkie.macalester.edu/csinparallel/modules/IntermediateIntroduction/build/html/ParallelSpeedup/ParallelSpeedup.html

#* Test -O3 makes a difference

#Mandelbrot
#You use the label "Image Width x Image Size". Surely the numbers marked are the sizes of each generated square? i.e. 125x125 ?
#More small data points could also be good on this graph. Change to log if necessary, and perhaps switch to seconds - if the majority of data points are over 1000 milliseconds.



# 1) I might need to make sure none of the math functions can divide by 0, as
#   it's not neccessarily undefined behaviour at compile time but an error.
#     - Only seems to be a problem in swaptions
# 2) work out a way to do step limits, technically can just use the par step limit
#   to work it out as I know they're the same. However a similar function to the timer
#   would be nice if possible.
# 3) I need to sort out a script for converting results to a csv or convert the way the
#    output from each test is put into a result file...
# 4) Remember I need to run these tests more than once, around 5 times. So this
#    is likely to take a while

# blackscholes works: x
# mandelbrot: x
# par_nbody:
# swaptions: X

# NOTE: You can always ignore the first Print Time Stamp in the output, it
# appears to be an unfortunate side affect of initilization or inclusion...

# NOTE: It will be worth mentioning in the paper that I had to remove a lot of
# the NAN checks etc from the math functions to allow swaptions to run, as
# compile time computation is a lot more stringent on this and errors out

# NOTE: Can I concatanate all the results into 1 .csv file? To do this I need to
# work out how to cut out the first "fake" print statement, a very cheap hack is
# to just count that we've entered the if statement more than once before
# printing. Might not work though some tests seem to have more than 1 warmup
# pass... mandelbrot for example

# NOTE: It may be possible to do the constexpr steps similarly to the timer, it
# depends on if the steps are carried over to the next call location, otherwise
# it becomes a little bit difficult to get an accurate number of steps. Needs
# some looking into.

declare -a filenames
declare -a bins

# Translates all the little time files into one big file
function convert_time_files_to_csv_file {
  declare -a floatingsecond
  declare -a miliseconds

  VALUE_COUNTER=0
  FILE_COUNTER=0
  NEXT_VAL=true
  NUM_FILES=${#filenames[@]}

#3  echo ${filenames[*]}

  local i
  for i in "${filenames[@]}"
  do
    FILE_COUNTER="$FILE_COUNTER + 1"
#4    echo "$i"
    NUM_LINES=$(wc -l < "$i")
    while read line; do
      if [ "$NEXT_VAL" = true ] ; then
        if (("$FILE_COUNTER" == "$NUM_FILES")); then
          floatingsecond+="$line"
        else
          floatingsecond+="$line,"
        fi
        NEXT_VAL=false
      else
        if (("$FILE_COUNTER" == "$NUM_FILES")); then
          miliseconds+="$line"
        else
          miliseconds+="$line,"
        fi
        NEXT_VAL=true
      fi

    done < "$i"
  done

#  echo "$2 ?"
  echo ${floatingsecond[*]} > $2_floatingsec.csv
  echo ${miliseconds[*]} > $2_milisecond.csv
}

function execute_blackscholes_lin {
  echo "Executing Blackscholes: Linear, -DBLACKSCHOLES_$1, -DNRUN_$2, -DCONSTEXPR_TRACK_$3"

  $CLANGOZ_ROOT/bin/clang++ -O3 -DCONSTEXPR_TRACK_$3 -DBLACKSCHOLES_$1 -DNRUN_$2 -fconstexpr-steps=4294967295 -w -I$CEST_INCLUDE -std=c++2a -stdlib=libc++ ../../cexpr_blackscholes.cpp -o lin_blackscholes$1_run$2_$3.o &> lin_blackscholes$1_run$2_result_$3

  filenames+=( "lin_blackscholes$1_run$2_result_$3" )
  bins+=( "lin_blackscholes$1_run$2_$3.o" )
}

function execute_blackscholes_par {
  echo "Executing Blackscholes: Parallel, -DBLACKSCHOLES_$1, -DNRUN_$2, Number of Cores $3, -DCONSTEXPR_TRACK_$4"

  $CLANGOZ_ROOT/bin/clang++ -O3 -DCONSTEXPR_TRACK_$4 -DCONSTEXPR_PARALLEL -DBLACKSCHOLES_$1 -DNRUN_$2 -fconstexpr-steps=4294967295 -w -fconstexpr-parallel-partition-size=$3 -fexperimental-constexpr-parallel -I$CEST_INCLUDE -std=c++2a -stdlib=libc++ ../../cexpr_blackscholes.cpp -o par_blackscholes$1_run$2_cores$3_$4.o &> par_blackscholes$1_run$2_cores$3_result_$4

  filenames+=( "par_blackscholes$1_run$2_cores$3_result_$4" )
  bins+=( "par_blackscholes$1_run$2_cores$3_$4.o" )
}

function execute_nbody_lin {
  echo "Executing nbody: Linear, -DNITERS_$1, -DNBODIES_$2, -DCONSTEXPR_TRACK_$3"
  $CLANGOZ_ROOT/bin/clang++ -O3 -DCONSTEXPR_TRACK_$3 -DNITERS_$1 -DNBODIES_$2 -fconstexpr-steps=4294967295 -w -I$CEST_INCLUDE -std=c++2a -stdlib=libc++ ../../cexpr_nbody.cpp -o lin_nbody_niters$1_nbodies$2_$3.o &> lin_nbody_niters$1_nbodies$2_results_$3

  filenames+=( "lin_nbody_niters$1_nbodies$2_results_$3" )
  bins+=( "lin_nbody_niters$1_nbodies$2_$3.o" )
}

function execute_nbody_par {
  echo "Executing nbody: Parallel, -DNITERS_$1, -DNBODIES_$2, Number of Cores $3, -DCONSTEXPR_TRACK_$4"
  $CLANGOZ_ROOT/bin/clang++ -O3 -DCONSTEXPR_TRACK_$4 -DCONSTEXPR_PARALLEL -DNITERS_$1 -DNBODIES_$2 -fconstexpr-steps=4294967295 -w -fconstexpr-parallel-partition-size=$3 -fexperimental-constexpr-parallel -I$CEST_INCLUDE -std=c++2a -stdlib=libc++ ../../cexpr_nbody.cpp -o par_nbody_niters$1_nbodies$2_cores$3_$4.o &> par_nbody_niters$1_nbodies$2_cores$3_results_$4

  filenames+=( "par_nbody_niters$1_nbodies$2_cores$3_results_$4" )
  bins+=( "par_nbody_niters$1_nbodies$2_cores$3_$4.o" )
}

function execute_mandelbrot_lin {
  echo "Executing mandelbrot: Linear, -DSZ=$1, -DMAXITERS=$2, -DCONSTEXPR_TRACK_$3"
  $CLANGOZ_ROOT/bin/clang++ -O3 -DCONSTEXPR_TRACK_$3 -DSZ=$1 -DMAXITERS=$2 -fconstexpr-steps=4294967295 -w -I$CEST_INCLUDE -std=c++2a -stdlib=libc++ ../../cexpr_mandelbrot.cpp -o lin_mandelbrot_hxw$1_maxiters$2_$3.o &> lin_mandelbrot_hxw$1_maxiters$2_results_$3

  filenames+=( "lin_mandelbrot_hxw$1_maxiters$2_results_$3" )
  bins+=( "lin_mandelbrot_hxw$1_maxiters$2_$3.o" )
}

function execute_mandelbrot_par {
  echo "Executing mandelbrot: Parallel, -DSZ=$1, -DMAXITERS=$2, Number of Cores $3, -DCONSTEXPR_TRACK_$4"
  $CLANGOZ_ROOT/bin/clang++ -O3 -DCONSTEXPR_TRACK_$4 -DCONSTEXPR_PARALLEL -DSZ=$1 -DMAXITERS=$2 -fconstexpr-steps=4294967295 -w -fconstexpr-parallel-partition-size=$3 -fexperimental-constexpr-parallel -I$CEST_INCLUDE -std=c++2a -stdlib=libc++ ../../cexpr_mandelbrot.cpp -o par_mandelbrot_hxw$1_maxiters$2_cores$3_$4.o &> par_mandelbrot_hxw$1_maxiters$2_cores$3_results_$4

  filenames+=( "par_mandelbrot_hxw$1_maxiters$2_cores$3_results_$4" )
  bins+=( "par_mandelbrot_hxw$1_maxiters$2_cores$3_$4.o" )
}

function execute_swaptions_lin {
  echo "Executing swaptions: Linear, -DNTRIALS_$1, -DNSWAPTIONS_$2, -DCONSTEXPR_TRACK_$3"
  $CLANGOZ_ROOT/bin/clang++ -O3 -DCONSTEXPR_TRACK_$3 -DNTRIALS_$1 -DNSWAPTIONS_$2 -fconstexpr-steps=4294967295 -w -I$CEST_INCLUDE -std=c++2a -stdlib=libc++ ../../cexpr_swaptions.cpp -o lin_swaptions_ntrials$1_nswaptions$2_$3.o &> lin_swaptions_ntrials$1_nswaptions$2_results_$3

  filenames+=( "lin_swaptions_ntrials$1_nswaptions$2_results_$3" )
  bins+=( "lin_swaptions_ntrials$1_nswaptions$2_$3.o" )
}

function execute_swaptions_par {
  echo "Executing swaptions: Parallel, -DNTRIALS_$1, -DNSWAPTIONS_$2, Number of Cores $3, -DCONSTEXPR_TRACK_$4"
  $CLANGOZ_ROOT/bin/clang++ -O3 -DCONSTEXPR_TRACK_$4 -DCONSTEXPR_PARALLEL -DNTRIALS_$1 -DNSWAPTIONS_$2 -fconstexpr-steps=4294967295 -w -fconstexpr-parallel-partition-size=$3 -fexperimental-constexpr-parallel -I$CEST_INCLUDE -std=c++2a -stdlib=libc++ ../../cexpr_swaptions.cpp -o par_swaptions_ntrials$1_nswaptions$2_cores$3_$4.o &> par_swaptions_ntrials$1_nswaptions$2_cores$3_results_$4

  filenames+=( "par_swaptions_ntrials$1_nswaptions$2_cores$3_results_$4" )
  bins+=( "par_swaptions_ntrials$1_nswaptions$2_cores$3_$4.o" )
}

# Compile program that creates headers that contain image data from images
function compile_image_to_text_file {
  $CLANGOZ_ROOT/bin/clang++ -std=c++2a -w ../../sycl/image_to_text_file.cpp -o ../../sycl/image_to_text_file `pkg-config --cflags --libs opencv4`
}

function execute_sycl_edge_detection_lin {
  echo "Executing SYCL Edge Detection: Linear, Image HxW: $1 -DCONSTEXPR_TRACK_$2"

  # Generating header containing image data
  cd ../../sycl/
  ./image_to_text_file image_data/$1.png
  cd - > /dev/null

  $CLANGOZ_ROOT/bin/clang++ -O3 -DCONSTEXPR_SYCL -DCONSTEXPR_TRACK_$2 -fconstexpr-steps=4294967295 -w -I$CEST_INCLUDE -I$MOTORSYCL_INCLUDE -std=c++2a -stdlib=libc++ ../../sycl/cexpr_sycl_edge_detection.cpp -o lin_cexpr_sycl_edge_detection_hxw$1_results.o &> lin_cexpr_sycl_edge_detection_hxw$1_results_$2

  filenames+=( "lin_cexpr_sycl_edge_detection_hxw$1_results_$2" )
  bins+=( "lin_cexpr_sycl_edge_detection_hxw$1_results.o" )
}

function execute_sycl_edge_detection_par {
  echo "Executing SYCL Edge Detection: Parallel, Image HxW: $1, Number of Cores $2, -DCONSTEXPR_TRACK_$3"

  # Generating header containing image data
  cd ../../sycl/
  ./image_to_text_file image_data/$1.png
  cd - > /dev/null

  $CLANGOZ_ROOT/bin/clang++ -O3 -DCONSTEXPR_SYCL -DCONSTEXPR_PARALLEL -DCONSTEXPR_TRACK_$3 -fconstexpr-steps=4294967295 -w -fconstexpr-parallel-partition-size=$2 -fexperimental-constexpr-parallel -I$CEST_INCLUDE -I$MOTORSYCL_INCLUDE -std=c++2a -stdlib=libc++ ../../sycl/cexpr_sycl_edge_detection.cpp -o par_cexpr_sycl_edge_detection_hxw$1_cores$2.o &> par_cexpr_sycl_edge_detection_hxw$1_cores$2_results_$3

  filenames+=( "par_cexpr_sycl_edge_detection_hxw$1_cores$2_results_$3" )
  bins+=( "par_cexpr_sycl_edge_detection_hxw$1_cores$2.o" )
}

# TODO: currently a bit buggy for the serial binaries size comparison using stat,
# because the text modification is slightly wrong, but currently not using the
# size in any graphs.... so leaving it buggy for now.
function print_binary_sets_size {
  local -n binary_arr=$1

  declare -a kbs
  declare -a bytes

  local i
  for i in "${binary_arr[@]}"
  do
#5    echo $i
    FILESIZE=$(stat -c%s "$i")
#6    echo "FileSize in bytes: $FILESIZE"
    bytes+="$FILESIZE,"
    KB=$(bc <<< "scale=2;$FILESIZE / 1000")
#7    echo "FileSize in kB (bytes / 1000): $KB"
    kbs+="$KB,"
  done

  echo ${kbs[*]} > $2_kb.csv
  echo ${bytes[*]} > $2_bytes.csv
}

function execute_benchmarks {

local i j prefix

mkdir $1
cd $1

unset bins filenames

################################################################################
#                                 Blackscholes
################################################################################

# Blackscholes can have the number of runs varied and the data set increased in
# size. The number of runs doesn't alter the results, it simply uses the same
# data set to calculate the same result. Verification of the results is done
# inside the program. Runs of the max size can take up to 2-3 minutes.

mkdir blackscholes_results
cd blackscholes_results

# Used this for final data set
for (( i = 0; i < num_bs_sizes; i++ ));
do
  execute_blackscholes_lin "${bs_sizes[$i]}" 1 "TIME"
done

print_binary_sets_size bins "blackscholes_1_run_lin_memory"
convert_time_files_to_csv_file $filenames "blackscholes_1_run_lin_timings"
unset bins filenames

for (( i = 0; i < NUM_CORE_SIZES; i++ )); do

  # Used this for final data set
  for (( j = 0; j < num_bs_sizes; j++ )); do
    execute_blackscholes_par "${bs_sizes[$j]}" 1 "${CORE_COUNTS[$i]}" "TIME"
    prefix="blackscholes_1_run_"${CORE_COUNTS[$i]}"_core_par"
    print_binary_sets_size bins ${prefix}"_memory"
    convert_time_files_to_csv_file $filenames ${prefix}"_timings"
    unset bins filenames
  done

done

cd - > /dev/null

################################################################################
#                                 Mandelbrot
################################################################################

mkdir mandelbrot_results
cd mandelbrot_results

# Used this for final data set
for ((i = 0; i < num_mand_sizes; i++));
do
  execute_mandelbrot_lin "${mand_sizes[$i]}" 128 "TIME"
done

print_binary_sets_size bins "mandelbrot_128_iter_lin_memory"
convert_time_files_to_csv_file $filenames "mandelbrot_128_iter_lin_timings"
unset bins filenames

for (( i = 0; i < NUM_CORE_SIZES; i++ )); do

  for (( j = 0; j < num_mand_sizes; j++ )); do
    execute_mandelbrot_par "${mand_sizes[$j]}" 128 "${CORE_COUNTS[$i]}" "TIME"
    prefix="mandelbrot_128_iter_par_"${CORE_COUNTS[$i]}"_core"
    print_binary_sets_size bins ${prefix}"_memory"
    convert_time_files_to_csv_file $filenames ${prefix}"_timings"
    unset bins filenames
  done

done

cd - > /dev/null

################################################################################
#                                 Swaptions
################################################################################

mkdir swaptions_results
cd swaptions_results

for ((i = 0; i < num_swap_sizes; i++));
do
  execute_swaptions_lin 2000 "${swap_sizes[$i]}" "TIME"
done

print_binary_sets_size bins "swaptions_2000_trials_lin_memory"
convert_time_files_to_csv_file $filenames "swaptions_2000_trials_lin_timings"
unset bins filenames

for (( i = 0; i < NUM_CORE_SIZES; i++ )); do

  for (( j = 0; j < num_swap_sizes; j++ )); do
    execute_swaptions_par 2000 "${swap_sizes[$j]}" "${CORE_COUNTS[$i]}" "TIME"
    prefix="swaptions_2000_trials_par_"${CORE_COUNTS[$i]}"_core"
    print_binary_sets_size bins ${prefix}"_memory"
    convert_time_files_to_csv_file $filenames ${prefix}"_timings"
    unset bins filenames
  done

done

cd - > /dev/null

################################################################################
#                                 nbody
################################################################################

mkdir nbody_results
cd nbody_results

for ((i = 0; i < num_nbody_sizes; i++));
do
  execute_nbody_lin 32 "${nbody_sizes[$i]}" "TIME"
done

print_binary_sets_size bins "nbody_15_body_lin_memory"
convert_time_files_to_csv_file $filenames "nbody_15_body_lin_timings"
unset bins filenames

for (( i = 0; i < NUM_CORE_SIZES; i++ )); do

  for (( j = 0; j < num_nbody_sizes; j++ )); do
    execute_nbody_par 32 "${nbody_sizes[$j]}" "${CORE_COUNTS[$i]}" "TIME"
    prefix="nbody_15_body_"${CORE_COUNTS[$i]}"_core_par"
    print_binary_sets_size bins ${prefix}"_memory"
    convert_time_files_to_csv_file $filenames ${prefix}"_timings"
    unset bins filenames
  done

done

cd - > /dev/null

################################################################################
#                           SYCL EDGE DETECTION
################################################################################

if [[ ! -z "$MOTORSYCL_INCLUDE" ]]; then
  mkdir sycl_edge_detection_results
  cd sycl_edge_detection_results

  compile_image_to_text_file

  for ((i = 0; i < num_edge_sizes; i++));
  do
    execute_sycl_edge_detection_lin "${edge_sizes[$i]}" "TIME"
  done

  print_binary_sets_size bins "sycl_edge_detection_lin_memory"
  convert_time_files_to_csv_file $filenames "sycl_edge_detection_lin_timings"
  unset bins filenames

  for (( i = 0; i < NUM_CORE_SIZES; i++ )); do

    for (( j = 0; j < num_edge_sizes; j++ )); do
      execute_nbody_par 32 "${edge_sizes[$j]}" "${CORE_COUNTS[$i]}" "TIME"
      prefix="sycl_edge_detection_"${CORE_COUNTS[$i]}"_core_par"
      print_binary_sets_size bins ${prefix}"_memory"
      convert_time_files_to_csv_file $filenames ${prefix}"_timings"
      unset bins filenames
    done

  done

  cd - > /dev/null
fi

cd - > /dev/null

}

if [[ -z "$1" ]]; then
  EXECUTE_COUNT=5
else
  EXECUTE_COUNT="$1"
fi

for ((index=0; index<EXECUTE_COUNT; index++)); do
  execute_benchmarks benchmark_run_$index
done

