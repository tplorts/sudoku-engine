require "./SudokuSolver"

solver = SudokuSolver.new("../puzzles/20190220a.sudoku")

puts "Before"
solver.print_grid

solver.solve

puts "\n\nAfter"
solver.print_grid
