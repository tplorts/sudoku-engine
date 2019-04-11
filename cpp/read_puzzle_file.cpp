#include "common.h"
#include <fstream>
#include <iostream>
#include <regex>
#include <string>

using namespace std;

void parse_line(const string &line, int numbers[]) {
  if (!regex_match(line, regex("^[ 1-9]{9}$"))) {
    cerr << "Improper line from puzzle file: " << line << endl;
    exit(EXIT_FAILURE);
  }

  for (size_t i = 0; i < N; i++) {
    char c = line[i];
    numbers[i] = c == ' ' ? 0 : int(c - '0');
  }
}

void read_puzzle_file(const string &filename, int grid[N][N]) {
  ifstream puzzle_file;
  puzzle_file.open(filename);

  if (!puzzle_file.is_open()) {
    cerr << "Could not load puzzle from " << filename << endl;
    exit(EXIT_FAILURE);
  }

  string line;
  for (size_t i = 0; getline(puzzle_file, line); i++) {
    parse_line(line, grid[i]);
  }

  puzzle_file.close();
}
