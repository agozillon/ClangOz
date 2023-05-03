#!/bin/bash

# Run, and then select "export as pdf"

gnuplot -p -s -e set terminal qt size 1800,1000 -c blackscholes.gnuplot
