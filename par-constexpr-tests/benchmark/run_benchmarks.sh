#!/bin/bash



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

# Translates all the little constexpr step files into one big file
function convert_step_files_to_csv_file {
  declare -a steps

  VALUE_COUNTER=0
  FILE_COUNTER=0
  NEXT_VAL=true
  NUM_FILES=${#filenames[@]}

  echo ${filenames[*]}

  for i in "${filenames[@]}"
  do
    FILE_COUNTER="$FILE_COUNTER + 1"
    echo "$i"
    while read line; do
      if (("$FILE_COUNTER" == "$NUM_FILES")); then
        steps+="$line"
      else
        steps+="$line,"
      fi
    done < "$i"
  done
  
  echo ${steps[*]} > $2_cexpr_step.csv
}

# Translates all the little time files into one big file
function convert_time_files_to_csv_file {
  declare -a floatingsecond
  declare -a miliseconds
  
  VALUE_COUNTER=0
  FILE_COUNTER=0
  NEXT_VAL=true
  NUM_FILES=${#filenames[@]}

 echo ${filenames[*]}

  for i in "${filenames[@]}"
  do
    FILE_COUNTER="$FILE_COUNTER + 1"
    echo "$i"
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

  time $CLANGOZ/bin/clang++ -O3 -DCONSTEXPR_TRACK_$3 -DBLACKSCHOLES_$1 -DNRUN_$2 -fconstexpr-steps=4294967295 -w -I$CEST_INCLUDE -std=c++2a -stdlib=libc++ ../../cexpr_blackscholes.cpp -o lin_blackscholes$1_run$2_$3.o &> lin_blackscholes$1_run$2_result_$3
  
  filenames+=( "lin_blackscholes$1_run$2_result_$3" )
  bins+=( "lin_blackscholes$1_run$2_$3.o" )
}

function execute_blackscholes_par {
  echo "Executing Blackscholes: Parallel, -DBLACKSCHOLES_$1, -DNRUN_$2, Number of Cores $3, -DCONSTEXPR_TRACK_$4"

  time $CLANGOZ/bin/clang++ -O3 -DCONSTEXPR_TRACK_$4 -DCONSTEXPR_PARALLEL -DBLACKSCHOLES_$1 -DNRUN_$2 -fconstexpr-steps=4294967295 -w -fconstexpr-parallel-partition-size=$3 -fexperimental-constexpr-parallel -I$CEST_INCLUDE -std=c++2a -stdlib=libc++ ../../cexpr_blackscholes.cpp -o par_blackscholes$1_run$2_cores$3_$4.o &> par_blackscholes$1_run$2_cores$3_result_$4

  filenames+=( "par_blackscholes$1_run$2_cores$3_result_$4" )
  bins+=( "par_blackscholes$1_run$2_cores$3_$4.o" )
}

function execute_nbody_lin {
  echo "Executing nbody: Linear, -DNITERS_$1, -DNBODIES_$2, -DCONSTEXPR_TRACK_$3"
  time $CLANGOZ/bin/clang++ -O3 -DCONSTEXPR_TRACK_$3 -DNITERS_$1 -DNBODIES_$2 -fconstexpr-steps=4294967295 -w -I$CEST_INCLUDE -std=c++2a -stdlib=libc++ ../../cexpr_nbody.cpp -o lin_nbody_niters$1_nbodies$2_$3.o &> lin_nbody_niters$1_nbodies$2_results_$3
  
  filenames+=( "lin_nbody_niters$1_nbodies$2_results_$3" )
  bins+=( "lin_nbody_niters$1_nbodies$2_$3.o" )
}

function execute_nbody_par {
  echo "Executing nbody: Parallel, -DNITERS_$1, -DNBODIES_$2, Number of Cores $3, -DCONSTEXPR_TRACK_$4"
  time $CLANGOZ/bin/clang++ -O3 -DCONSTEXPR_TRACK_$4 -DCONSTEXPR_PARALLEL -DNITERS_$1 -DNBODIES_$2 -fconstexpr-steps=4294967295 -w -fconstexpr-parallel-partition-size=$3 -fexperimental-constexpr-parallel -I$CEST_INCLUDE -std=c++2a -stdlib=libc++ ../../cexpr_nbody.cpp -o par_nbody_niters$1_nbodies$2_cores$3_$4.o &> par_nbody_niters$1_nbodies$2_cores$3_results_$4
  
  filenames+=( "par_nbody_niters$1_nbodies$2_cores$3_results_$4" )
  bins+=( "par_nbody_niters$1_nbodies$2_cores$3_$4.o" )
}

function execute_mandelbrot_lin {
  echo "Executing mandelbrot: Linear, -DHXW_$1, -DMAXITERS_$2, -DCONSTEXPR_TRACK_$3"
  time $CLANGOZ/bin/clang++ -O3 -DCONSTEXPR_TRACK_$3 -DHXW_$1 -DMAXITERS_$2 -fconstexpr-steps=4294967295 -w -I$CEST_INCLUDE -std=c++2a -stdlib=libc++ ../../cexpr_mandelbrot.cpp -o lin_mandelbrot_hxw$1_maxiters$2.o &> lin_mandelbrot_hxw$1_maxiters$2_results_$3

  filenames+=( "lin_mandelbrot_hxw$1_maxiters$2_results_$3" )
  bins+=( "lin_mandelbrot_hxw$1_maxiters$2_$3.o" )
}

function execute_mandelbrot_par {
  echo "Executing mandelbrot: Parallel, -DHXW_$1, -DMAXITERS_$2, Number of Cores $3, -DCONSTEXPR_TRACK_$4"
  time $CLANGOZ/bin/clang++ -O3 -DCONSTEXPR_TRACK_$4 -DCONSTEXPR_PARALLEL -DHXW_$1 -DMAXITERS_$2 -fconstexpr-steps=4294967295 -w -fconstexpr-parallel-partition-size=$3 -fexperimental-constexpr-parallel -I$CEST_INCLUDE -std=c++2a -stdlib=libc++ ../../cexpr_mandelbrot.cpp -o par_mandelbrot_hxw$1_maxiters$2_cores$3_$4.o &> par_mandelbrot_hxw$1_maxiters$2_cores$3_results_$4
  
  filenames+=( "par_mandelbrot_hxw$1_maxiters$2_cores$3_results_$4" )
  bins+=( "par_mandelbrot_hxw$1_maxiters$2_cores$3_$4.o" )
}

function execute_swaptions_lin {
  echo "Executing swaptions: Linear, -DNTRIALS_$1, -DNSWAPTIONS_$2, -DCONSTEXPR_TRACK_$3"
  time $CLANGOZ/bin/clang++ -O3 -DCONSTEXPR_TRACK_$3 -DNTRIALS_$1 -DNSWAPTIONS_$2 -fconstexpr-steps=4294967295 -w -I$CEST_INCLUDE -std=c++2a -stdlib=libc++ ../../cexpr_swaptions.cpp -o lin_swaptions_ntrials$1_nswaptions$2_$3.o &> lin_swaptions_ntrials$1_nswaptions$2_results_$3
  
  filenames+=( "lin_swaptions_ntrials$1_nswaptions$2_results_$3" )
  bins+=( "lin_swaptions_ntrials$1_nswaptions$2_$3.o" )
}

function execute_swaptions_par {
  echo "Executing swaptions: Parallel, -DNTRIALS_$1, -DNSWAPTIONS_$2, Number of Cores $3, -DCONSTEXPR_TRACK_$4"
  time $CLANGOZ/bin/clang++ -O3 -DCONSTEXPR_TRACK_$4 -DCONSTEXPR_PARALLEL -DNTRIALS_$1 -DNSWAPTIONS_$2 -fconstexpr-steps=4294967295 -w -fconstexpr-parallel-partition-size=$3 -fexperimental-constexpr-parallel -I$CEST_INCLUDE -std=c++2a -stdlib=libc++ ../../cexpr_swaptions.cpp -o par_swaptions_ntrials$1_nswaptions$2_cores$3_$4.o &> par_swaptions_ntrials$1_nswaptions$2_cores$3_results_$4
  
  filenames+=( "par_swaptions_ntrials$1_nswaptions$2_cores$3_results_$4" )
  bins+=( "par_swaptions_ntrials$1_nswaptions$2_cores$3_$4.o" )
}

# Compile program that creates headers that contain image data from images
function compile_image_to_text_file {
  $CLANGOZ/bin/clang++ -std=c++2a -w ../../sycl/image_to_text_file.cpp -o ../../sycl/image_to_text_file `pkg-config --cflags --libs opencv4`
}

function execute_sycl_edge_detection_lin {
  echo "Executing SYCL Edge Detection: Linear, Image HxW: $1 -DCONSTEXPR_TRACK_$2"

  # Generating header containing image data
  pushd ../../sycl/ 
  ./image_to_text_file image_data/$1.png
  popd

  time $CLANGOZ/bin/clang++ -O3 -D_LIBCPP_HAS_PARALLEL_ALGORITHMS -DCONSTEXPR_SYCL -DCONSTEXPR_TRACK_$2 -fconstexpr-steps=4294967295 -w -I$PSTL_GEN -I$CEST_INCLUDE -I$MOTORSYCL_INCLUDE -I$PSTL -std=c++2a -stdlib=libc++ ../../sycl/cexpr_sycl_edge_detection.cpp -o lin_cexpr_sycl_edge_detection_hxw$1_results.o &> lin_cexpr_sycl_edge_detection_hxw$1_results_$2

  filenames+=( "lin_cexpr_sycl_edge_detection_hxw$1_results_$2" )
  bins+=( "lin_cexpr_sycl_edge_detection_hxw$1_results.o" )
}

function execute_sycl_edge_detection_par {
  echo "Executing SYCL Edge Detection: Parallel, Image HxW: $1, Number of Cores $2, -DCONSTEXPR_TRACK_$3"
  
  # Generating header containing image data
  pushd ../../sycl/ 
  ./image_to_text_file image_data/$1.png
  popd
    
  time $CLANGOZ/bin/clang++ -O3 -DCONSTEXPR_SYCL -DCONSTEXPR_PARALLEL -DCONSTEXPR_TRACK_$3 -fconstexpr-steps=4294967295 -w -fconstexpr-parallel-partition-size=$2 -fexperimental-constexpr-parallel -I$PSTL_GEN -I$CEST_INCLUDE -I$MOTORSYCL_INCLUDE -I$PSTL -std=c++2a -stdlib=libc++ ../../sycl/cexpr_sycl_edge_detection.cpp -o par_cexpr_sycl_edge_detection_hxw$1_cores$2.o &> par_cexpr_sycl_edge_detection_hxw$1_cores$2_results_$3

  filenames+=( "par_cexpr_sycl_edge_detection_hxw$1_cores$2_results_$3" )
  bins+=( "par_cexpr_sycl_edge_detection_hxw$1_cores$2.o" )
}

function print_binary_sets_size {
  local -n binary_arr=$1
  
  declare -a kbs
  declare -a bytes

  for i in "${binary_arr[@]}"
  do
    echo $i
    FILESIZE=$(stat -c%s "$i")
    echo "FileSize in bytes: $FILESIZE"
    bytes+="$FILESIZE,"
    KB=$(bc <<< "scale=2;$FILESIZE / 1000")
    echo "FileSize in kB (bytes / 1000): $KB"
    kbs+="$KB,"
  done

  echo ${kbs[*]} > $2_kb.csv
  echo ${bytes[*]} > $2_bytes.csv
}

function execute_benchmarks {

mkdir $1
pushd $1

unset filenames
unset bins

################################################################################
#                                 Blackscholes
################################################################################

# Blackscholes can have the number of runs varied and the data set increased in 
# size. The number of runs doesn't alter the results, it simply uses the same 
# data set to calculate the same result. Verification of the results is done 
# inside the program. Runs of the max size can take up to 2-3 minutes.

#mkdir blackscholes_results
#pushd blackscholes_results

# # Used this for final data set
#execute_blackscholes_lin 4 1 "TIME"
#execute_blackscholes_lin 16 1 "TIME"
#execute_blackscholes_lin 1K 1 "TIME"
#execute_blackscholes_lin 4K 1 "TIME"
#execute_blackscholes_lin 16K 1 "TIME"
#execute_blackscholes_lin 64K 1 "TIME"

#print_binary_sets_size bins "blackscholes_1_run_lin_memory"
#unset bins
#convert_time_files_to_csv_file $filenames "blackscholes_1_run_lin_timings"
#unset filenames

## Used this for final data set
#execute_blackscholes_par 4 1 2 "TIME"
#execute_blackscholes_par 16 1 2 "TIME"
#execute_blackscholes_par 1K 1 2 "TIME"
#execute_blackscholes_par 4K 1 2 "TIME"
#execute_blackscholes_par 16K 1 2 "TIME"
#execute_blackscholes_par 64K 1 2 "TIME"

#print_binary_sets_size bins "blackscholes_1_run_2_core_par_memory"
#unset bins
#convert_time_files_to_csv_file $filenames "blackscholes_1_run_2_core_par_timings"
#unset filenames

## Used this for final data set
#execute_blackscholes_par 4 1 4 "TIME"
#execute_blackscholes_par 16 1 4 "TIME"
#execute_blackscholes_par 1K 1 4 "TIME"
#execute_blackscholes_par 4K 1 4 "TIME"
#execute_blackscholes_par 16K 1 4 "TIME"
#execute_blackscholes_par 64K 1 4 "TIME"

#print_binary_sets_size bins "blackscholes_1_run_4_core_par_memory"
#unset bins
#convert_time_files_to_csv_file $filenames "blackscholes_1_run_4_core_par_timings"
#unset filenames

## Used this for final data set
#execute_blackscholes_par 4 1 6 "TIME"
#execute_blackscholes_par 16 1 6 "TIME"
#execute_blackscholes_par 1K 1 6 "TIME"
#execute_blackscholes_par 4K 1 6 "TIME"
#execute_blackscholes_par 16K 1 6 "TIME"
#execute_blackscholes_par 64K 1 6 "TIME"

#print_binary_sets_size bins "blackscholes_1_run_6_core_par_memory"
#unset bins
#convert_time_files_to_csv_file $filenames "blackscholes_1_run_6_core_par_timings"
#unset filenames


## Used this for final data set
#execute_blackscholes_par 4 1 8 "TIME"
#execute_blackscholes_par 16 1 8 "TIME"
#execute_blackscholes_par 1K 1 8 "TIME"
#execute_blackscholes_par 4K 1 8 "TIME"
#execute_blackscholes_par 16K 1 8 "TIME"
#execute_blackscholes_par 64K 1 8 "TIME"

#print_binary_sets_size bins "blackscholes_1_run_8_core_par_memory"
#unset bins
#convert_time_files_to_csv_file $filenames "blackscholes_1_run_8_core_par_timings"
#unset filenames

#popd

################################################################################
#                                 Mandelbrot
################################################################################

#mkdir mandelbrot_results
#pushd mandelbrot_results

## Used this for final data set
#execute_mandelbrot_lin 25 128 "TIME"
#execute_mandelbrot_lin 50 128 "TIME" 
#execute_mandelbrot_lin 75 128 "TIME"
#execute_mandelbrot_lin 100 128 "TIME"
#execute_mandelbrot_lin 125 128 "TIME"

#print_binary_sets_size bins "mandelbrot_128_iter_lin_memory"
#unset bins
#convert_time_files_to_csv_file $filenames "mandelbrot_128_iter_lin_timings"
#unset filenames

## Used this for final data set
#execute_mandelbrot_par 25 128 2 "TIME"
#execute_mandelbrot_par 50 128 2 "TIME"
#execute_mandelbrot_par 75 128 2 "TIME"
#execute_mandelbrot_par 100 128 2 "TIME"
#execute_mandelbrot_par 125 128 2 "TIME"

#print_binary_sets_size bins "mandelbrot_128_iter_par_2_core_memory"
#unset bins
#convert_time_files_to_csv_file $filenames "mandelbrot_128_iter_par_2_core_timings"
#unset filenames

## Used this for final data set
#execute_mandelbrot_par 25 128 4 "TIME"
#execute_mandelbrot_par 50 128 4 "TIME"
#execute_mandelbrot_par 75 128 4 "TIME"
#execute_mandelbrot_par 100 128 4 "TIME"
#execute_mandelbrot_par 125 128 4 "TIME"

#print_binary_sets_size bins "mandelbrot_128_iter_par_4_core_memory"
#unset bins
#convert_time_files_to_csv_file $filenames "mandelbrot_128_iter_par_4_core_timings"
#unset filenames

## Used this for final data set
#execute_mandelbrot_par 25 128 6 "TIME"
#execute_mandelbrot_par 50 128 6 "TIME"
#execute_mandelbrot_par 75 128 6 "TIME"
#execute_mandelbrot_par 100 128 6 "TIME"
#execute_mandelbrot_par 125 128 6 "TIME"

#print_binary_sets_size bins "mandelbrot_128_iter_par_6_core_memory"
#unset bins
#convert_time_files_to_csv_file $filenames "mandelbrot_128_iter_par_6_core_timings"
#unset filenames

## Used this for final data set
#execute_mandelbrot_par 25 128 8 "TIME"
#execute_mandelbrot_par 50 128 8 "TIME"
#execute_mandelbrot_par 75 128 8 "TIME"
#execute_mandelbrot_par 100 128 8 "TIME"
#execute_mandelbrot_par 125 128 8 "TIME"

#print_binary_sets_size bins "mandelbrot_128_iter_par_8_core_memory"
#unset bins
#convert_time_files_to_csv_file $filenames "mandelbrot_128_iter_par_8_core_timings"
#unset filenames

#popd

################################################################################
#                                 Swaptions
################################################################################

mkdir swaptions_results
pushd swaptions_results

execute_swaptions_lin 2000 2 "TIME"
execute_swaptions_lin 2000 4 "TIME"
execute_swaptions_lin 2000 6 "TIME"
execute_swaptions_lin 2000 8 "TIME"
execute_swaptions_lin 2000 10 "TIME"

print_binary_sets_size bins "swaptions_2000_trials_lin_memory"
unset bins
convert_time_files_to_csv_file $filenames "swaptions_2000_trials_lin_timings"
unset filenames

execute_swaptions_par 2000 2 2 "TIME"
execute_swaptions_par 2000 4 2 "TIME"
execute_swaptions_par 2000 6 2 "TIME"
execute_swaptions_par 2000 8 2 "TIME"
execute_swaptions_par 2000 10 2 "TIME" 

print_binary_sets_size bins "swaptions_2000_trials_par_2_core_memory"
unset bins
convert_time_files_to_csv_file $filenames "swaptions_2000_trials_par_2_core_timings"
unset filenames

execute_swaptions_par 2000 2 4 "TIME"
execute_swaptions_par 2000 4 4 "TIME"
execute_swaptions_par 2000 6 4 "TIME"
execute_swaptions_par 2000 8 4 "TIME"
execute_swaptions_par 2000 10 4 "TIME"

print_binary_sets_size bins "swaptions_2000_trials_par_4_core_memory"
unset bins
convert_time_files_to_csv_file $filenames "swaptions_2000_trials_par_4_core_timings"
unset filenames

execute_swaptions_par 2000 2 6 "TIME"
execute_swaptions_par 2000 4 6 "TIME"
execute_swaptions_par 2000 6 6 "TIME"
execute_swaptions_par 2000 8 6 "TIME"
execute_swaptions_par 2000 10 6 "TIME"

print_binary_sets_size bins "swaptions_2000_trials_par_6_core_memory"
unset bins
convert_time_files_to_csv_file $filenames "swaptions_2000_trials_par_6_core_timings"
unset filenames

execute_swaptions_par 2000 2 8 "TIME"
execute_swaptions_par 2000 4 8 "TIME"
execute_swaptions_par 2000 6 8 "TIME"
execute_swaptions_par 2000 8 8 "TIME"
execute_swaptions_par 2000 10 8 "TIME"

print_binary_sets_size bins "swaptions_2000_trials_par_8_core_memory"
unset bins
convert_time_files_to_csv_file $filenames "swaptions_2000_trials_par_8_core_timings"
unset filenames

popd

################################################################################
#                                 nbody
################################################################################

#mkdir nbody_results
#pushd nbody_results

#execute_nbody_lin 32 16 "TIME"
#execute_nbody_lin 32 32 "TIME"
#execute_nbody_lin 32 64 "TIME"
#execute_nbody_lin 32 128 "TIME"
#execute_nbody_lin 32 256 "TIME"

#print_binary_sets_size bins "nbody_15_body_lin_memory"
#unset bins
#convert_time_files_to_csv_file $filenames "nbody_15_body_lin_timings"
#unset filenames

#execute_nbody_par 32 16 2 "TIME"
#execute_nbody_par 32 32 2 "TIME"
#execute_nbody_par 32 64 2 "TIME"
#execute_nbody_par 32 128 2 "TIME"
#execute_nbody_par 32 256 2 "TIME"

#print_binary_sets_size bins "nbody_15_body_2_core_par_memory"
#unset bins
#convert_time_files_to_csv_file $filenames "nbody_15_body_2_core_par_timings"
#unset filenames

#execute_nbody_par 32 16 4 "TIME"
#execute_nbody_par 32 32 4 "TIME"
#execute_nbody_par 32 64 4 "TIME"
#execute_nbody_par 32 128 4 "TIME"
#execute_nbody_par 32 256 4 "TIME"

#print_binary_sets_size bins "nbody_15_body_4_core_par_memory"
#unset bins
#convert_time_files_to_csv_file $filenames "nbody_15_body_4_core_par_timings"
#unset filenames

#execute_nbody_par 32 16 6 "TIME"
#execute_nbody_par 32 32 6 "TIME"
#execute_nbody_par 32 64 6 "TIME"
#execute_nbody_par 32 128 6 "TIME"
#execute_nbody_par 32 256 6 "TIME"

#print_binary_sets_size bins "nbody_15_body_6_core_par_memory"
#unset bins
#convert_time_files_to_csv_file $filenames "nbody_15_body_6_core_par_timings"
#unset filenames

#execute_nbody_par 32 16 8 "TIME"
#execute_nbody_par 32 32 8 "TIME"
#execute_nbody_par 32 64 8 "TIME"
#execute_nbody_par 32 128 8 "TIME"
#execute_nbody_par 32 256 8 "TIME"

#print_binary_sets_size bins "nbody_15_body_8_core_par_memory"
#unset bins
#convert_time_files_to_csv_file $filenames "nbody_15_body_8_core_par_timings"
#unset filenames

#popd

################################################################################
#                           SYCL EDGE DETECTION
################################################################################


#if [[ ! -z "$PSTL_GEN" && ! -z "$MOTORSYCL_INCLUDE" && ! -z "$PSTL" && ! -z "$CEST_INCLUDE" ]]; then
#  mkdir sycl_edge_detection_results
#  pushd sycl_edge_detection_results

#  compile_image_to_text_file

#  execute_sycl_edge_detection_lin 64 "TIME"
#  execute_sycl_edge_detection_lin 128 "TIME"
#  execute_sycl_edge_detection_lin 256 "TIME"
#  execute_sycl_edge_detection_lin 512 "TIME"

#  print_binary_sets_size bins "sycl_edge_detection_lin_memory"
#  unset bins
#  convert_time_files_to_csv_file $filenames "sycl_edge_detection_lin_timings"
#  unset filenames

#  execute_sycl_edge_detection_par 64 2 "TIME"
#  execute_sycl_edge_detection_par 128 2 "TIME"
#  execute_sycl_edge_detection_par 256 2 "TIME"
#  execute_sycl_edge_detection_par 512 2 "TIME"

#  print_binary_sets_size bins "sycl_edge_detection_2_core_par_memory"
#  unset bins
#  convert_time_files_to_csv_file $filenames "sycl_edge_detection_2_core_par_timings"
#  unset filenames

#  execute_sycl_edge_detection_par 64 4 "TIME"
#  execute_sycl_edge_detection_par 128 4 "TIME"
#  execute_sycl_edge_detection_par 256 4 "TIME"
#  execute_sycl_edge_detection_par 512 4 "TIME"

#  print_binary_sets_size bins "sycl_edge_detection_4_core_par_memory"
#  unset bins
#  convert_time_files_to_csv_file $filenames "sycl_edge_detection_4_core_par_timings"
#  unset filenames
#  
#  execute_sycl_edge_detection_par 64 6 "TIME"
#  execute_sycl_edge_detection_par 128 6 "TIME"
#  execute_sycl_edge_detection_par 256 6 "TIME"
#  execute_sycl_edge_detection_par 512 6 "TIME"

#  print_binary_sets_size bins "sycl_edge_detection_6_core_par_memory"
#  unset bins
#  convert_time_files_to_csv_file $filenames "sycl_edge_detection_6_core_par_timings"
#  unset filenames

#  execute_sycl_edge_detection_par 64 8 "TIME"
#  execute_sycl_edge_detection_par 128 8 "TIME"
#  execute_sycl_edge_detection_par 256 8 "TIME"
#  execute_sycl_edge_detection_par 512 8 "TIME"

#  print_binary_sets_size bins "sycl_edge_detection_8_core_par_memory"
#  unset bins
#  convert_time_files_to_csv_file $filenames "sycl_edge_detection_8_core_par_timings"
#  unset filenames
#  
#  popd
#fi

popd
 
}

function execute_benchmarks_for_steps {

mkdir $1
pushd $1

unset filenames
unset bins

################################################################################
#                                 Blackscholes
################################################################################

# Blackscholes can have the number of runs varied and the data set increased in 
# size. The number of runs doesn't alter the results, it simply uses the same 
# data set to calculate the same result. Verification of the results is done 
# inside the program. Runs of the max size can take up to 2-3 minutes.

mkdir blackscholes_results
pushd blackscholes_results

 # Used this for final data set
execute_blackscholes_lin 4 1 "STEPS"
execute_blackscholes_lin 16 1 "STEPS"
execute_blackscholes_lin 1K 1 "STEPS"
execute_blackscholes_lin 4K 1 "STEPS"
execute_blackscholes_lin 16K 1 "STEPS"
execute_blackscholes_lin 64K 1 "STEPS"

convert_step_files_to_csv_file $filenames "blackscholes_1_run_lin_steps"
unset filenames
unset bins

# Used this for final data set
execute_blackscholes_par 4 1 2 "STEPS"
execute_blackscholes_par 16 1 2 "STEPS"
execute_blackscholes_par 1K 1 2 "STEPS"
execute_blackscholes_par 4K 1 2 "STEPS"
execute_blackscholes_par 16K 1 2 "STEPS"
execute_blackscholes_par 64K 1 2 "STEPS"

convert_step_files_to_csv_file $filenames "blackscholes_1_run_2_core_par_steps"
unset filenames
unset bins

# Used this for final data set
execute_blackscholes_par 4 1 4 "STEPS"
execute_blackscholes_par 16 1 4 "STEPS"
execute_blackscholes_par 1K 1 4 "STEPS"
execute_blackscholes_par 4K 1 4 "STEPS"
execute_blackscholes_par 16K 1 4 "STEPS"
execute_blackscholes_par 64K 1 4 "STEPS"

convert_step_files_to_csv_file $filenames "blackscholes_1_run_4_core_par_steps"
unset filenames
unset bins

# Used this for final data set
execute_blackscholes_par 4 1 6 "STEPS"
execute_blackscholes_par 16 1 6 "STEPS"
execute_blackscholes_par 1K 1 6 "STEPS"
execute_blackscholes_par 4K 1 6 "STEPS"
execute_blackscholes_par 16K 1 6 "STEPS"
execute_blackscholes_par 64K 1 6 "STEPS"

convert_step_files_to_csv_file $filenames "blackscholes_1_run_6_core_par_steps"
unset filenames
unset bins

# Used this for final data set
execute_blackscholes_par 4 1 8 "STEPS"
execute_blackscholes_par 16 1 8 "STEPS"
execute_blackscholes_par 1K 1 8 "STEPS"
execute_blackscholes_par 4K 1 8 "STEPS"
execute_blackscholes_par 16K 1 8 "STEPS"
execute_blackscholes_par 64K 1 8 "STEPS"

convert_step_files_to_csv_file $filenames "blackscholes_1_run_8_core_par_steps"
unset filenames
unset bins

popd

################################################################################
#                                 Mandelbrot
################################################################################

mkdir mandelbrot_results
pushd mandelbrot_results

# Used this for final data set
execute_mandelbrot_lin 25 128 "STEPS"
execute_mandelbrot_lin 50 128 "STEPS" 
execute_mandelbrot_lin 75 128 "STEPS"
execute_mandelbrot_lin 100 128 "STEPS"
execute_mandelbrot_lin 125 128 "STEPS"

convert_step_files_to_csv_file $filenames "mandelbrot_128_iter_lin_steps"
unset filenames
unset bins

# Used this for final data set
execute_mandelbrot_par 25 128 2 "STEPS"
execute_mandelbrot_par 50 128 2 "STEPS"
execute_mandelbrot_par 75 128 2 "STEPS"
execute_mandelbrot_par 100 128 2 "STEPS"
execute_mandelbrot_par 125 128 2 "STEPS"

convert_step_files_to_csv_file $filenames "mandelbrot_128_iter_par_2_core_steps"
unset filenames
unset bins

## Used this for final data set
execute_mandelbrot_par 25 128 4 "STEPS"
execute_mandelbrot_par 50 128 4 "STEPS"
execute_mandelbrot_par 75 128 4 "STEPS"
execute_mandelbrot_par 100 128 4 "STEPS"
execute_mandelbrot_par 125 128 4 "STEPS"

convert_step_files_to_csv_file $filenames "mandelbrot_128_iter_par_4_core_steps"
unset filenames
unset bins

## Used this for final data set
execute_mandelbrot_par 25 128 6 "STEPS"
execute_mandelbrot_par 50 128 6 "STEPS"
execute_mandelbrot_par 75 128 6 "STEPS"
execute_mandelbrot_par 100 128 6 "STEPS"
execute_mandelbrot_par 125 128 6 "STEPS"

convert_step_files_to_csv_file $filenames "mandelbrot_128_iter_par_6_core_steps"
unset filenames
unset bins

# Used this for final data set
execute_mandelbrot_par 25 128 8 "STEPS"
execute_mandelbrot_par 50 128 8 "STEPS"
execute_mandelbrot_par 75 128 8 "STEPS"
execute_mandelbrot_par 100 128 8 "STEPS"
execute_mandelbrot_par 125 128 8 "STEPS"

convert_step_files_to_csv_file $filenames "mandelbrot_128_iter_par_8_core_steps"
unset filenames
unset bins

popd

################################################################################
#                                 Swaptions
################################################################################

mkdir swaptions_results
pushd swaptions_results

execute_swaptions_lin 2000 2 "STEPS"
execute_swaptions_lin 2000 4 "STEPS"
execute_swaptions_lin 2000 6 "STEPS"
execute_swaptions_lin 2000 8 "STEPS"
execute_swaptions_lin 2000 10 "STEPS"

convert_step_files_to_csv_file $filenames "swaptions_2000_trials_lin_steps"
unset filenames
unset bins

execute_swaptions_par 2000 2 2 "STEPS"
execute_swaptions_par 2000 4 2 "STEPS"
execute_swaptions_par 2000 6 2 "STEPS"
execute_swaptions_par 2000 8 2 "STEPS"
execute_swaptions_par 2000 10 2 "STEPS" 

convert_step_files_to_csv_file $filenames "swaptions_2000_trials_par_2_core_steps"
unset filenames
unset bins

execute_swaptions_par 2000 2 4 "STEPS"
execute_swaptions_par 2000 4 4 "STEPS"
execute_swaptions_par 2000 6 4 "STEPS"
execute_swaptions_par 2000 8 4 "STEPS"
execute_swaptions_par 2000 10 4 "STEPS"

convert_step_files_to_csv_file $filenames "swaptions_2000_trials_par_4_core_steps"
unset filenames
unset bins

execute_swaptions_par 2000 2 6 "STEPS"
execute_swaptions_par 2000 4 6 "STEPS"
execute_swaptions_par 2000 6 6 "STEPS"
execute_swaptions_par 2000 8 6 "STEPS"
execute_swaptions_par 2000 10 6 "STEPS"

convert_step_files_to_csv_file $filenames "swaptions_2000_trials_par_6_core_steps"
unset filenames
unset bins

execute_swaptions_par 2000 2 8 "STEPS"
execute_swaptions_par 2000 4 8 "STEPS"
execute_swaptions_par 2000 6 8 "STEPS"
execute_swaptions_par 2000 8 8 "STEPS"
execute_swaptions_par 2000 10 8 "STEPS"

convert_step_files_to_csv_file $filenames "swaptions_2000_trials_par_8_core_steps"
unset filenames
unset bins

popd

################################################################################
#                                 nbody
################################################################################

mkdir nbody_results
pushd nbody_results

execute_nbody_lin 32 16 "STEPS"
execute_nbody_lin 32 32 "STEPS"
execute_nbody_lin 32 64 "STEPS"
execute_nbody_lin 32 128 "STEPS"
execute_nbody_lin 32 256 "STEPS"

convert_step_files_to_csv_file $filenames "nbody_15_body_lin_steps"
unset filenames
unset bins

execute_nbody_par 32 16 2 "STEPS"
execute_nbody_par 32 32 2 "STEPS"
execute_nbody_par 32 64 2 "STEPS"
execute_nbody_par 32 128 2 "STEPS"
execute_nbody_par 32 256 2 "STEPS"

convert_step_files_to_csv_file $filenames "nbody_15_body_2_core_par_steps"
unset filenames
unset bins

execute_nbody_par 32 16 4 "STEPS"
execute_nbody_par 32 32 4 "STEPS"
execute_nbody_par 32 64 4 "STEPS"
execute_nbody_par 32 128 4 "STEPS"
execute_nbody_par 32 256 4 "STEPS"

convert_step_files_to_csv_file $filenames "nbody_15_body_4_core_par_steps"
unset filenames
unset bins

execute_nbody_par 32 16 6 "STEPS"
execute_nbody_par 32 32 6 "STEPS"
execute_nbody_par 32 64 6 "STEPS"
execute_nbody_par 32 128 6 "STEPS"
execute_nbody_par 32 256 6 "STEPS"

convert_step_files_to_csv_file $filenames "nbody_15_body_6_core_par_steps"
unset filenames
unset bins

execute_nbody_par 32 16 8 "STEPS"
execute_nbody_par 32 32 8 "STEPS"
execute_nbody_par 32 64 8 "STEPS"
execute_nbody_par 32 128 8 "STEPS"
execute_nbody_par 32 256 8 "STEPS"

convert_step_files_to_csv_file $filenames "nbody_15_body_8_core_par_steps"
unset filenames
unset bins

popd


################################################################################
#                           SYCL EDGE DETECTION
################################################################################


  # Not sure how good this test is for calculating number of steps as it 
  # encompases multiple launches of the parallel for_each for each kernel
if [[ ! -z "$PSTL_GEN" && ! -z "$MOTORSYCL_INCLUDE" && ! -z "$PSTL" && ! -z "$CEST_INCLUDE" ]]; then
  mkdir sycl_edge_detection_results
  pushd sycl_edge_detection_results

  compile_image_to_text_file
  
  execute_sycl_edge_detection_lin 64 "STEPS"
  execute_sycl_edge_detection_lin 128 "STEPS"
  execute_sycl_edge_detection_lin 256 "STEPS"
  execute_sycl_edge_detection_lin 512 "STEPS"
  
  convert_step_files_to_csv_file $filenames "sycl_edge_detect_lin_steps"
  unset filenames
  unset bins

  execute_sycl_edge_detection_par 64 2 "STEPS"
  execute_sycl_edge_detection_par 128 2 "STEPS"
  execute_sycl_edge_detection_par 256 2 "STEPS"
  execute_sycl_edge_detection_par 512 2 "STEPS"

  convert_step_files_to_csv_file $filenames "sycl_edge_detect_2_core_par_steps"
  unset filenames
  unset bins
  
  execute_sycl_edge_detection_par 64 4 "STEPS"
  execute_sycl_edge_detection_par 128 4 "STEPS"
  execute_sycl_edge_detection_par 256 4 "STEPS"
  execute_sycl_edge_detection_par 512 4 "STEPS"
  
  convert_step_files_to_csv_file $filenames "sycl_edge_detect_4_core_par_steps"
  unset filenames
  unset bins
  
  execute_sycl_edge_detection_par 64 6 "STEPS"
  execute_sycl_edge_detection_par 128 6 "STEPS"
  execute_sycl_edge_detection_par 256 6 "STEPS"
  execute_sycl_edge_detection_par 512 6 "STEPS"
  
  convert_step_files_to_csv_file $filenames "sycl_edge_detect_6_core_par_steps"
  unset filenames
  unset bins
  
  execute_sycl_edge_detection_par 64 8 "STEPS"
  execute_sycl_edge_detection_par 128 8 "STEPS"
  execute_sycl_edge_detection_par 256 8 "STEPS"
  execute_sycl_edge_detection_par 512 8 "STEPS"
  
  convert_step_files_to_csv_file $filenames "sycl_edge_detect_8_core_par_steps"
  unset filenames
  unset bins
  
  popd
fi

popd

}

if [[ -z "$1" ]]; then
  EXECUTE_COUNT=5
else
  EXECUTE_COUNT="$1"
fi

for ((index=0; index<EXECUTE_COUNT; index++)); do
  execute_benchmarks benchmark_run_$index
done

# this could be done cleaner, but I feel it's fine the way it is for times sake
#execute_benchmarks_for_steps benchmark_step_data
  

