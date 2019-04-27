#include "Solver.h"
#include "fs.h"
#include <chrono>
#include <iostream>
#include <map>
#include <numeric>
#include <regex>
#include <set>
#include <string>
#include <vector>

using namespace std;
using namespace Sudoku;

template <typename Operation> double measure_duration(Operation operate) {
  auto start_time = chrono::steady_clock::now();
  operate();
  auto end_time = chrono::steady_clock::now();
  chrono::duration<double, milli> elapsed = end_time - start_time;
  return elapsed.count();
}

const regex sudoku_filename_regex("\\d+([a-z])\\.sudoku");
const string puzzles_path = "../puzzles";

string get_difficulty_code(const string& filename) {
  smatch match;

  if (regex_match(filename, match, sudoku_filename_regex) &&
      match.size() == 2) {
    return match[1].str();
  }

  return "";
}

template <typename List> set<string> get_difficulty_codes(List filenames) {
  set<string> difficulties;

  for (auto& filename : filenames) {
    difficulties.insert(get_difficulty_code(filename));
  }

  return difficulties;
}

typedef vector<double> Durations;
typedef map<string, Durations> DurationsMap;

template <typename KeyCollection>
DurationsMap initialize_durations_map(KeyCollection keys) {
  DurationsMap durations_map;

  for (auto& key : keys) {
    durations_map[key] = Durations();
  }

  return durations_map;
}

double mean(vector<double> v) {
  return accumulate(v.begin(), v.end(), 0.0) / v.size();
}

int main() {
  auto puzzle_filenames = read_directory(puzzles_path, sudoku_filename_regex);
  auto difficulties = get_difficulty_codes(puzzle_filenames);
  auto durations_map = initialize_durations_map(difficulties);

  for (int i = 0; i < 100; i++) {
    for (auto& filename : puzzle_filenames) {
      Solver solver("../puzzles/" + filename);
      auto difficulty = get_difficulty_code(filename);

      auto duration = measure_duration([&]() { solver.solve(); });

      durations_map[difficulty].push_back(duration);
    }
  }

  for (const auto& entry : durations_map) {
    cout << entry.first << ": " << mean(entry.second) << " ms" << endl;
  }

  return 0;
}
