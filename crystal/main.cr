require "./Solver"

solver = Sudoku::Solver.new(
  "../puzzles/20190220b.sudoku",
  debug_output_enabled: true,
  validation_enabled: true
)

puts "Before"
solver.print_grid

solver.solve

puts "\n\nAfter"
solver.print_grid
