require "./Solver"

solver = Sudoku::Solver.new(
  "../puzzles/20190220b.sudoku",
  debug_output_enabled: true,
  # debug_validation_enabled: true
)

puts "starting state"
puts solver.state.grid.to_verbose_s

begin
  completed = solver.solve

  puts "\n\ndone"
  if completed
    puts completed.state.grid.to_s
  end
rescue exception
  puts exception
  puts solver.state.grid.to_verbose_s
end
