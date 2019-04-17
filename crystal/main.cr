require "./Solver"

solver = Sudoku::Solver.new(
  "../puzzles/20190220b.sudoku",
  debug_output_enabled: true,
  validation_enabled: true
)

puts "Before"
solver.print_grid

begin
  solver.solve
rescue exception
  puts solver.sudoku.grid.to_verbose_s
end

puts "\n\nAfter"
solver.print_grid
