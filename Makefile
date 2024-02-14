all: plumedProfiler pbcProfiler

%.o:%.cxx
	$(CXX) $< -c -O3 -Og

plumedProfiler: main.o
	$(CXX) $< -o $@ -std=c++11 -O3 -Og -lplumedWrapper -ldl

pbcProfiler: pbc.o
	$(CXX) $< -o $@ -std=c++11 -O3 -Og -lplumedKernel -ldl