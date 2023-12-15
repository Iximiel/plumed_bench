/*
compile this program with, e.g.:

clang++ -std=c++11 -O3 -I /opt/local/include/ main.cpp -L /opt/local/lib
-lplumedWrapper

then run as:

./a.out ~/plumed2/tmp/test-htt/install-master/lib/libplumedKernel.dylib
*/

/*//////////////////////////////////////////////////////////////////////////////
ORIGINAL https://gist.github.com/GiovanniBussi/8a44ba30a8d66f8566caa121e9f652d0
//////////////////////////////////////////////////////////////////////////////*/

#include "plumed/wrapper/Plumed.h"
#include <chrono>
#include <iostream>
#include <vector>

void test(const std::string &path) {
  int natoms = 100000;
  int nframes = 20000;
  auto p = PLMD::Plumed::dlopen(path.c_str());
  // p.cmd("setLogFile","/dev/null");
  p.cmd("setNatoms", natoms);
  p.cmd("init");

  p.cmd("readInputLines", "c0: CENTER ATOMS=1-1000\n"
                          "c1: CENTER ATOMS=1-100000\n"
                          "all: CENTER ATOMS=c0,c1\n"
                          "pos: POSITION ATOM=all\n"
                          "RESTRAINT ARG=pos.x AT=0.0 KAPPA=1\n");

  std::vector<double> posit(3 * natoms, 0.0);
  std::vector<double> force(3 * natoms, 0.0);
  std::vector<double> masses(natoms);
  for (auto i = 0; i < natoms; i++)
    masses[i] = i + 1;

  auto beg = std::chrono::high_resolution_clock::now();

  for (unsigned iframe = 0; iframe < nframes; iframe++) {
    for (auto i = 0; i < natoms; i++) {
      posit[3 * i + 0] = i * iframe;
      posit[3 * i + 1] = i * iframe + 1;
      posit[3 * i + 2] = i * iframe + 2;
    }
    double cell[9];
    double virial[9];
    for (auto i = 0; i < 9; i++)
      cell[i] = 0.0;
    for (auto i = 0; i < 9; i++)
      virial[i] = 0.0;
    std::fill(force.begin(), force.end(), 0.0);

    p.cmd("setStep", 0);
    p.cmd("setBox", cell);
    p.cmd("setVirial", virial);
    p.cmd("setMasses", masses.data());
    p.cmd("setPositions", posit.data());
    p.cmd("setForces", force.data());
    p.cmd("calc");
  }

  auto end = std::chrono::high_resolution_clock::now();
  auto duration =
      std::chrono::duration_cast<std::chrono::microseconds>(end - beg);
  std::cout << "Elapsed Time: " << duration.count() << "\n";
}

int main(int argc, const char *argv[]) {
  test(argv[1]);
  return 0;
}
