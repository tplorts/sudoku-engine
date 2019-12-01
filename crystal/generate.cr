require "./Solver"

state = nil
elapsed_time = Time.measure do
  state = Sudoku::Solver.generate
end.total_milliseconds

puts state.try(&.grid.to_s)

puts "#{elapsed_time.round(1)} ms"
