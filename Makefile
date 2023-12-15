all: plumedProfiler

%.o:%.cxx
	$(CXX) $< -c -O3 -Og

plumedProfiler: main.o
	$(CXX) $< -o $@ -std=c++11 -O3 -Og -lplumedWrapper -ldl