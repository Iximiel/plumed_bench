#!/bin/env bash

module purge
module load gnu9 plumed/currentMaster

#18_12 has an extra stopwatch
dirtype=plumed-24git
Extra=""
# colors="--colors io"
for name in htt; do

  fname=${name}${dirtype}${Extra}
  echo "just running \"./plumedProfiler \$HOME/scratch/installs/${name}${dirtype}/lib/libplumedKernel.so\""

  ./plumedProfiler $HOME/scratch/installs/${name}${dirtype}/lib/libplumedKernel.so | #>"${fname}.jr.out"
    sed -n -e '/Cycles        Total      Average      Minimum      Maximum/,$p' >"${fname}.jr.out"
done
