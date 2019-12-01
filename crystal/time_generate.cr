require "./Solver"

durations = (0...100).map do
  Time.measure { Sudoku::Solver.generate }.total_milliseconds
end

puts "#{(durations.sum / durations.size).round(1)} ms"
