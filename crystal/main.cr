require "./Solver"

solver = Solver.new("../puzzles/20190220a.sudoku", debug_output_enabled: true)

puts "Before"
solver.print_grid

solver.solve

puts "\n\nAfter"
solver.print_grid
