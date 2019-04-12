#include "Section.h"
#include "common.h"

using namespace Sudoku;

void Section::place(const cell_t value) {
  has_map[value] = true;

  SectionIterator* iterator = get_iterator();
  while (!iterator->done()) {
    iterator->next().eliminate_candidate(value);
  }

  delete iterator;
}
