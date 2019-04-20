require "spec"
require "../../Solver"

include Sudoku

solver_a = Solver.new("../puzzles/20190220a.sudoku")

describe "Solver clone" do
  solver_b = Solver.new(solver_a)

  it "should not be the same solver" do
    solver_b.should_not be solver_a
  end

  it "should not reference the same sudoku state" do
    solver_b.state.should_not be solver_a.state
  end
end
