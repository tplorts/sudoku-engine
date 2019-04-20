require "spec"
require "../../State"

include Sudoku

state_a = State.new

describe "State clone" do
  state_b = State.new(state_a)

  it "should not be the same state" do
    state_b.should_not be state_a
  end

  it "should not reference the same grid" do
    state_b.grid.should_not be state_a.grid
  end

  it "should not reference any of the same rows" do
    (0...N).each do |i|
      state_b.row(i).should_not be state_a.row(i)
    end
  end

  it "should not reference any of the same columns" do
    (0...N).each do |i|
      state_b.column(i).should_not be state_a.column(i)
    end
  end

  it "should not reference any of the same blocks" do
    (0...B).each do |br|
      (0...B).each do |bc|
        state_b.block(br, bc).should_not be state_a.block(br, bc)
      end
    end
  end
end
