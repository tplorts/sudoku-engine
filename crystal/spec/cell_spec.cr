require "spec"
require "../Cell"

include Sudoku

describe "Cell" do
  cell = Cell.new

  it "should start with a nil occupant" do
    cell.occupant.should be_nil
  end

  it "should start with all possible candidates" do
    cell.candidates.should eq ALL_CANDIDATES
  end

  describe "eliminate_candidate" do
    begin
      # Eliminate all but the final candidate
      (1...N).each { |n| cell.eliminate_candidate(n) }
    rescue error : InvalidCellError
      puts error.to_s
    end

    it "should now mark everything except #{N} as no longer a candidate" do
      cell.candidates[1...N].should eq BitArray.new(N - 1, false)
    end

    it "should still have #{N} as a candidate value" do
      cell.candidate?(N).should be_true
    end

    it "should raise a contradiction when eliminating the final candidate while still unoccupied" do
      expect_raises(CellContradiction) do
        cell.eliminate_candidate(N)
      end
    end

    it "should now have a contradictory candidate registry, like: #{NO_CANDIDATES_NO_OCCUPANT}" do
      cell.candidates.should eq NO_CANDIDATES_NO_OCCUPANT
    end
  end
end
