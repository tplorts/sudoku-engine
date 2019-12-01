#if !defined(_SUDOKU_SOLVER_H_)
#define _SUDOKU_SOLVER_H_

#include "Position.h"
#include "State.h"
#include <iostream>
#include <string>
#include <vector>

namespace Sudoku {

class Solver {
private:
  State* state;
  const bool shuffle_candidate_values;

  int empty_cell_count() const { return state->get_empty_cell_count(); }

  bool complete() { return empty_cell_count() == 0; }

  void place(cell_t value, const Position& position) {
    state->place(value, position);
  }

  template <typename Operation> void until_complete_or_stuck(Operation);

  Position position_with_fewest_candidates();

  std::vector<cell_t> get_candidate_values(const Cell& cell);
  void fill_determined_cells();
  void fill_determined_positions();
  void exhaustively_fill_determined_cells();
  void exhaustively_fill_determined_positions();
  std::vector<Position> find_candidate_positions(int value, const Section&);
  bool any_sections_have(const Position& position, int value);
  void solve_determined();
  void eliminate_candidates_by_partial_determination();
  Position find_determined_row_column_in_block(int value, const Block& block);
  void eliminate_candidate_in_section_except_in_block(int value,
                                                      const Section& section,
                                                      const Block& block);

public:
  Solver() : state(new State()), shuffle_candidate_values(true) {}

  Solver(const std::string& filename)
      : state(new State()), shuffle_candidate_values(false) {
    state->load_from_file(filename);
  }

  Solver(const Solver& source)
      : state(new State(*source.state)),
        shuffle_candidate_values(source.shuffle_candidate_values) {}

  ~Solver() {
    if (state != NULL) {
      delete state;
    }
  }

  void solve();

  static State generate();

  friend std::ostream& operator<<(std::ostream& outs, const Solver& solver);
};

inline std::ostream& operator<<(std::ostream& outs, const Solver& solver) {
  return outs << *solver.state;
}

} // namespace Sudoku

#endif // _SUDOKU_SOLVER_H_
