#if !defined(_SUDOKU_SECTION_H_)
#define _SUDOKU_SECTION_H_

#include "Cell.h"
#include "Grid.h"
#include "common.h"

namespace Sudoku {

class SectionIterator {
protected:
  const Grid& grid;
  int next_index;

public:
  SectionIterator(const Grid& grid) : grid(grid), next_index(0) {}

  virtual ~SectionIterator(){};

  virtual Cell& next() = 0;

  bool done() const { return next_index >= N; }
};

class Section {
protected:
  const Grid& grid;

  /**
   * N + 1 bits so that we can reference each bit according to
   * a 1-thru-N value directly (without having to ±1)
   */
  std::bitset<N + 1> has_map;

public:
  Section(const Grid& grid) : grid(grid) {}
  ~Section() {}

  bool has(const cell_t value) const { return has_map[value]; };

  virtual SectionIterator* get_iterator() = 0;

  void place(const cell_t value);
};

} // namespace Sudoku

#endif // _SUDOKU_SECTION_H_
