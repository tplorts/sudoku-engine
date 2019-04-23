require "./Solver"

solver = Sudoku::Solver.new(
  "../puzzles/20190220c.sudoku",
  debug_output_enabled: true,
  # debug_validation_enabled: true
)

puts "starting state"
puts solver.state.grid.to_verbose_s

begin
  solver.solve

  puts "\ndone"
  puts solver.state.grid.to_s
  if solver.complete?
    puts solver.valid? ? "valid" : "¡*invalid*!"
  else
    puts "incomplete :("
  end
rescue exception
  puts exception
  puts solver.state.grid.to_verbose_s
end
