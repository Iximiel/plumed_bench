#include "plumed/tools/Pbc.h"
#include "plumed/tools/Tensor.h"
#include "plumed/tools/Vector.h"
#include <chrono>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <vector>

using PLMD::Pbc;
using PLMD::Tensor;
using PLMD::Vector;
using std::vector;
using duration = std::chrono::nanoseconds;
using perfclock = std::chrono::steady_clock;

void test(int operations, int repeat, const Pbc &pbc, std::ostream &stream) {
  vector<Vector> distances(operations);
  Tensor box = pbc.getBox();
  box /= box.determinant();
  duration d = duration::zero();
  const double t = 1.0 / operations;
  for (auto r = 0u; r < repeat; ++r) {
    for (auto i = 0u; i < operations; ++i) {
      distances[i] = 4 * i * t * box.getRow(i % 3);
    }
    auto beg = perfclock::now();

    pbc.apply(distances);
    auto end = perfclock::now();
    d += std::chrono::duration_cast<duration>(end - beg);
  }
  // stream<< " " << d.count() << " us\n";
  stream << operations << " " << d.count() << "\n";
}

void testdistance(int operations, int repeat, const Pbc &pbc,
                  std::ostream &stream) {
  vector<Vector> distances(operations);
  Tensor box = pbc.getBox();
  box /= box.determinant();
  duration d = duration::zero();
  const double t = 1.0 / operations;
  for (auto r = 0u; r < repeat; ++r) {
    for (auto i = 0u; i < operations; ++i) {
      distances[i] = 4 * i * t * box.getRow(i % 3);
    }
    auto beg = perfclock::now();
    for (auto i = 0u; i < operations - 1; ++i) {
      pbc.distance(distances[i], distances[i + 1]);
    }
    auto end = perfclock::now();
    d += std::chrono::duration_cast<duration>(end - beg);
  }
  // stream<< " " << d.count() << " us\n";
  stream << operations << " " << d.count() << "\n";
}

void testqueue(int repeat, const Pbc &pbc, std::ostream &stream) {
  for (auto nvec = 10; nvec < 100000; nvec *= 10) {
    test(nvec, repeat, pbc, stream);
  }
}

void testdistqueue(int repeat, const Pbc &pbc, std::ostream &stream) {
  for (auto nvec = 10; nvec < 100000; nvec *= 10) {
    testdistance(nvec, repeat, pbc, stream);
  }
}

int main(int argc, char **argv) {
  constexpr auto nrepeats = 10000;
  if (argc > 1) {
    std::cout << argv[1] << "\n";
  }

  Pbc generic;
  generic.setBox({10.0, 0.0, 0.0, 5.0, 5.0, 0.0, 0.0, 0.0, 10.0});

  std::cout << "generic:\n";
  if (argc > 1) {
    {
      std::ofstream of(std::string(argv[1]) + "generic.dat");
      testqueue(nrepeats, generic, of);
    }
    {
      std::ofstream of(std::string(argv[1]) + "_dist_generic.dat");
      testdistqueue(nrepeats, generic, of);
    }
  } else {
    testqueue(nrepeats, generic, std::cout);
    testdistqueue(nrepeats, generic, std::cout);
  }
  Pbc ortho;
  ortho.setBox({10.0, 0.0, 0.0, 0.0, 10.0, 0.0, 0.0, 0.0, 10.0});
  std::cout << "ortho:\n";
  if (argc > 1) {
    {
      std::ofstream of(std::string(argv[1]) + "ortho.dat");
      testqueue(nrepeats, ortho, of);
    }
    {
      std::ofstream of(std::string(argv[1]) + "_dist_ortho.dat");
      testdistqueue(nrepeats, ortho, of);
    }
  } else {
    testqueue(nrepeats, ortho, std::cout);
    testdistqueue(nrepeats, ortho, std::cout);
  }

  return 0;
}
