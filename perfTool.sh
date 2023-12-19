#!/bin/env bash

module purge
module load gnu9 plumed/currentMaster
colors=
#git clone https://github.com/brendangregg/FlameGraph
flameDir=$HOME/scratch/repos/FlameGraph

#18_12 has an extra stopwatch
dirtype=plumed19_12
Extra="NoPbc-stopwatch-swcenter-more"
# colors="--colors io"
for name in master htt; do
  fname=${name}${dirtype}${Extra}
  echo "perfing \"./plumedProfiler \$HOME/scratch/installs/${name}${dirtype}/lib/libplumedKernel.so\""
  # -g Enables call-graph (stack chain/backtrace) recording for both kernel space and user space.
  # -o, --output= Output file name.
  # -F, --freq= Profile at this frequency. Use max to use the currently maximum allowed frequency, i.e. the value in the kernel.perf_event_max_sample_rate sysctl. Will throttle down to the currently maximum allowed frequency. See --strict-freq.
  perf record -F99 -g --output="${fname}.data" \
    ./plumedProfiler $HOME/scratch/installs/${name}${dirtype}/lib/libplumedKernel.so >"${fname}.out"
  # -i, --input= Input file name. (default: perf.data unless stdin is a fifo)
  perf script --input="${fname}.data" >"${fname}.perf"

  "${flameDir}"/stackcollapse-perf.pl "${fname}.perf" >"${fname}.folded"
  "${flameDir}"/flamegraph.pl "${fname}.folded" --cp ${colors} --subtitle ${fname} >"${fname}.svg"
  "${flameDir}"/flamegraph.pl "${fname}.folded" --cp ${colors} --subtitle ${fname} --flamechart >"${fname}.flamechart.svg"
  colors="--colors mem"
  #colors="--colors chain"
done
"${flameDir}"/difffolded.pl master${dirtype}${Extra}.folded htt${dirtype}${Extra}.folded |
  "${flameDir}"/flamegraph.pl --subtitle "diff master-htt ${dirtype}${Extra}" >diff_master-htt_${dirtype}${Extra}.svg
"${flameDir}"/difffolded.pl htt${dirtype}${Extra}.folded master${dirtype}${Extra}.folded |
  "${flameDir}"/flamegraph.pl --negate --subtitle "diff htt-master ${dirtype}${Extra}" >diff_htt-master_${dirtype}${Extra}.svg
