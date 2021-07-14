set grid
set termoption dashed
set size 0.98
set bmargin 10
set lmargin 18
set rmargin 8
set xtics offset 0,-1,0
set xlabel offset 0,-3,0
set ytics offset -1,-1,0
set ylabel offset -8,0,0
set key font ",30"
set xtics font ",35"
set ytics font ",35" 
set title "Blackscholes" font ",35"
set ylabel "Time Taken (Seconds)" font ",35"
set xlabel "Number of Input Data Points" font ",35"

#set style line 1 lw 1.5 pt 2 ps 5

#set logscale xy # log scaling on both axis

plot "blackscholes.dat" every ::0::5 using 2:1 title 'Serial' with linespoints dt 1 lw 3 ps 3, \
     "blackscholes.dat" every ::6::11 using 2:1 title '2 Threads' with linespoints dt 2 lw 3 ps 3, \
     "blackscholes.dat" every ::12::17 using 2:1 title '4 Threads' with linespoints dt 3 lw 3 ps 3, \
     "blackscholes.dat" every ::18::23 using 2:1 title '6 Threads' with linespoints dt 4 linecolor 8 lw 3 ps 3, \
     "blackscholes.dat" every ::24::29 using 2:1 title '8 Threads' with linespoints dt 5 linecolor 7 lw 3 ps 3 




