#if !defined(_SUDOKU_SOLVER_H_)
#define _SUDOKU_SOLVER_H_

#include "State.h"
#include <iostream>
#include <string>
#include <vector>

namespace Sudoku {

class Solver {
private:
  State sudoku;

  int empty_cell_count() const { return sudoku.get_empty_cell_count(); }

  bool complete() { return empty_cell_count() == 0; }

  void fill_determined_cells();
  void fill_determined_positions();
  void exhaustively_fill_determined_cells();
  void exhaustively_fill_determined_positions();
  std::vector<Position> find_candidate_positions(int value, const Block& block);
  void solve_determined();
  void eliminate_candidates_by_partial_determination();

public:
  Solver(const std::string& filename) { sudoku.load_from_file(filename); }
  ~Solver() {}

  void solve();

  friend std::ostream& operator<<(std::ostream& outs, const Solver& solver);
};

inline std::ostream& operator<<(std::ostream& outs, const Solver& solver) {
  return outs << solver.sudoku;
}

} // namespace Sudoku

#endif // _SUDOKU_SOLVER_H_
