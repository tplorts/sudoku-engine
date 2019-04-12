require "spec"
require "dir"
require "../State"
require "../Solver"

include Sudoku

difficulties = {
  easy: "a",
  # medium: "b",
  # hard:   "c",
}

describe Solver do
  difficulties.each do |difficulty_name, filename_part|
    describe difficulty_name do
      Dir["../puzzles/*#{filename_part}.sudoku"].each do |filename|
        describe filename do
          solver = Solver.new(filename)

          initially_valid = solver.valid?

          it "should be a valid sudoku to begin with" do
            initially_valid.should be_true
          end

          next if !initially_valid

          solver.solve
          it "should solve the sudoku" do
            solver.complete?.should be_true
          end

          it "should be a valid sudoku solution" do
            solver.valid?.should be_true
          end
        end
      end
    end
  end
end
