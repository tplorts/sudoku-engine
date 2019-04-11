CXX=g++
CXXFLAGS=-I.
DEPS=common.h read_puzzle_file.h State.h Grid.h Cell.h Section.h Row.h Column.h Block.h
OBJ=Solver.o State.o Grid.o Cell.o Section.o read_puzzle_file.o

debug: CXXFLAGS += -DDEBUG -g -O0
debug: solve

%.o: %.cpp $(DEPS)
	$(CXX) -c -o $@ $< $(CXXFLAGS)

solve: solve.cpp $(OBJ)
	$(CXX) -o $@ $^ $(CXXFLAGS)

clean:
	rm -r *.o solve *.dSYM
