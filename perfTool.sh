#!/bin/env bash

module purge
module load gnu9 plumed/currentMaster
colors=
#git clone https://github.com/brendangregg/FlameGraph
flameDir=$HOME/scratch/repos/FlameGraph

dirtype=plumed18_12flto

colors="--colors io"
for name in master htt; do
  fname=${name}${dirtype}
  echo "perfing \"./plumedProfiler \$HOME/scratch/installs/${fname}/lib/libplumedKernel.so\""
  perf record -F99 -g ./plumedProfiler $HOME/scratch/installs/${fname}/lib/libplumedKernel.so >"${fname}.out"
  perf script >"${fname}.perf"

  ${flameDir}/stackcollapse-perf.pl "${fname}.perf" >"${fname}.folded"
  ${flameDir}/flamegraph.pl "${fname}.folded" --cp ${colors} >"${fname}.svg"
  colors="--colors chain"
done

# name=master
# ${flameDir}/flamegraph.pl "${name}.folded" --cp >"${name}.svg"
# name=htt
# ${flameDir}/flamegraph.pl "${name}.folded" --cp --colors mem >"${name}.svg"
