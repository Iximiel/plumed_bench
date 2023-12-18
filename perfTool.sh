#!/bin/env bash

module purge
module load gnu9 plumed/currentMaster
colors=
#git clone https://github.com/brendangregg/FlameGraph
flameDir=$HOME/scratch/repos/FlameGraph

dirtype=plumed15_12
Extra=Nopbc
# colors="--colors io"
for name in master htt; do
  fname=${name}${dirtype}${Extra}
  echo "perfing \"./plumedProfiler \$HOME/scratch/installs/${name}${dirtype}/lib/libplumedKernel.so\""
  perf record -F99 -g ./plumedProfiler $HOME/scratch/installs/${name}${dirtype}/lib/libplumedKernel.so >"${fname}.out"
  perf script >"${fname}.perf"

  ${flameDir}/stackcollapse-perf.pl "${fname}.perf" >"${fname}.folded"
  ${flameDir}/flamegraph.pl "${fname}.folded" --cp ${colors} --subtitle ${fname} >"${fname}.svg"
  colors="--colors chain"
done
${flameDir}/difffolded.pl master${dirtype}${Extra}.folded htt${dirtype}${Extra}.folded |
  ${flameDir}/flamegraph.pl --subtitle "diff master-htt ${dirtype}${Extra}" >diff${dirtype}${Extra}.svg
