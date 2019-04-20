require "spec"
require "../../Cell"

include Sudoku

cell_a = Cell.new
cell_0 = Cell.new

describe "Cell clone" do
  cell_b = Cell.new(cell_a)

  it "should not be the same cell" do
    cell_b.should_not be cell_a
  end

  it "should have the same candidate values" do
    cell_b.candidates.should eq cell_a.candidates
  end

  describe "when placing a value in cell a" do
    cell_a.place(1)

    it "should change cell a’s value" do
      cell_a.occupant.should eq 1
    end

    it "should not affect cell b’s value" do
      cell_b.occupant.should be_nil
    end

    it "should eliminate all values from cell a’s candidates" do
      (1..N).each { |n| cell_a.candidates[n].should be_false }
    end

    it "should not affect cell b’s candidates" do
      (1..N).each { |n| cell_b.candidates[n].should be_true }
    end
  end

  describe "when eliminating a candidate from cell 1" do
    cell_1 = Cell.new(cell_0)

    # puts "\nBEFORE"
    # puts "cell 0: #{cell_0.to_verbose_s}"
    # puts cell_0.inspect
    # puts "cell 1: #{cell_1.to_verbose_s}"
    # puts cell_1.inspect

    cell_1.eliminate_candidate(1)

    # puts "\nAFTER"
    # puts "cell 0: #{cell_0.to_verbose_s}"
    # puts cell_0.inspect
    # puts "cell 1: #{cell_1.to_verbose_s}"
    # puts cell_1.inspect

    it "should eliminate the value from cell 1’s candidates" do
      cell_1.candidate?(1).should be_false
    end

    it "should not eliminate other values from cell 1’s candidates" do
      (2..N).each { |n| cell_1.candidate?(n).should be_true }
    end

    it "should not affect cell 0’s candidates" do
      (1..N).each { |n| cell_0.candidate?(n).should be_true }
    end
  end
end
