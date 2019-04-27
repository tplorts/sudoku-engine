require "dir"
require "./Solver"

file_paths = Dir["../puzzles/*.sudoku"].sort

durations_map = file_paths
  .map(&.[/\d+([a-z])/, 1])
  .to_set
  .map { |difficulty| {difficulty, [] of Float64} }
  .to_h

100.times do
  file_paths.each do |file_path|
    solver = Sudoku::Solver.new(file_path)
    name = file_path[/\d+[a-z]/]

    elapsed_time = Time.measure { solver.solve }.total_milliseconds

    raise "did not solve #{name}" unless solver.complete? && solver.valid?

    difficulty = name[/[a-z]/]
    durations_map[difficulty] << elapsed_time
  end
end

averages = durations_map
  .map { |key, durations| [key, (durations.sum / durations.size).round(3)] }
  .to_h

averages.each do |difficulty, average_time|
  puts "#{difficulty}: #{average_time} ms"
end
