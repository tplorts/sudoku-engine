#if !defined(_SUDOKU_SECTION_H_)
#define _SUDOKU_SECTION_H_

#include "Cell.h"
#include "Grid.h"
#include "Position.h"
#include "common.h"
#include <bitset>
#include <functional>

namespace Sudoku {

typedef std::function<void(const Position&)> PositionFunction;
typedef std::function<void(Cell&)> CellFunction;
typedef std::function<void(Cell&, const Position&)> CellPositionFunction;

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

  void place(const cell_t value);

  virtual void each_position(PositionFunction) const = 0;
  void each_cell(CellFunction) const;
  void each_cell_with_position(CellPositionFunction) const;
};

} // namespace Sudoku

#endif // _SUDOKU_SECTION_H_
