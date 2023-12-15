#!/bin/env bash

module purge
module load gnu9 plumed
colors=
#git clone https://github.com/brendangregg/FlameGraph
flameDir=$HOME/scratch/repos/FlameGraph

for name in master htt; do
  perf record -F99 -g ./plumedProfiler $HOME/scratch/installs/${name}plumed15_12/lib/libplumedKernel.so
  perf script >"${name}.perf"

  ${flameDir}/stackcollapse-perf.pl "${name}.perf" >"${name}.folded"
  ${flameDir}/flamegraph.pl "${name}.folded" --cp ${colors} >"${name}.svg"
  colors="--colors mem"
done

# name=master
# ${flameDir}/flamegraph.pl "${name}.folded" --cp >"${name}.svg"
# name=htt
# ${flameDir}/flamegraph.pl "${name}.folded" --cp --colors mem >"${name}.svg"
