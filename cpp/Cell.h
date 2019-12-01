#if !defined(_SUDOKU_CELL_H_)
#define _SUDOKU_CELL_H_

#include "common.h"
#include <bitset>
#include <iostream>
#include <stdexcept>
#include <vector>

namespace Sudoku {

typedef int cell_t;

class CellContradiction : public std::logic_error {
public:
  CellContradiction() : std::logic_error("cell contradiction") {}
};

class Cell {
private:
  cell_t value;

  // Using N (not N+1) here so that .count() below is accurate
  std::bitset<N> candidates;

public:
  Cell() : value(0) {
    // Start an empty cell with all possible candidate values
    candidates.set();
  }

  Cell(const Cell& source)
      : value(source.value), candidates(source.candidates) {}

  ~Cell() {}

  cell_t get_value() const { return value; }

  bool occupied() const { return bool(value); }

  bool is_candidate(cell_t n) const { return candidates[n - 1]; }

  void place(cell_t new_value);

  void eliminate_candidate(cell_t candidate_value);

  bool determined() const { return !occupied() && candidates.count() == 1; }

  cell_t first_candidate() const;

  int candidate_count() const { return candidates.count(); }

  std::vector<cell_t> candidate_values() const;
  std::vector<cell_t> shuffled_candidate_values() const;

  friend std::ostream& operator<<(std::ostream& outs, const Cell& cell) {
    return cell.occupied() ? (outs << cell.get_value()) : (outs << ' ');
  }
};

} // namespace Sudoku

#endif // _SUDOKU_CELL_H_
