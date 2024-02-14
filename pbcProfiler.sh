#!/bin/bash

module purge
module load gnu9
ldpathmunge() {
  case ":${LD_LIBRARY_PATH}:" in
  *:"$1":*) ;;
  *)
    if [ "$2" = "after" ]; then
      LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$1
    else
      LD_LIBRARY_PATH=$1:$LD_LIBRARY_PATH
    fi
    ;;
  esac
}

for dirplace in master080224 optimize-pbc; do
  # for dirplace in arrayPbcPerfInlineTool; do
  (
    ldpathmunge $HOME/scratch/installs/${dirplace}/lib/
    # echo $dirplace
    # ldd ./pbcProfiler
    ./pbcProfiler $dirplace
    #$HOME/scratch/installs/${dirplace}/bin/plumed info --git-version
  )

done
