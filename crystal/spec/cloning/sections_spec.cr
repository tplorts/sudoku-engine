require "spec"
require "../../Sections"

include Sudoku

grid_a = Grid.new
row_a = Row.new(grid_a, 3)

describe "Row clone" do
  grid_b = Grid.new
  row_b = Row.new(grid_b, row_a)

  it "should not be the same row" do
    row_b.should_not be row_a
  end

  it "should have the same row index" do
    row_b.index.should eq row_a.index
  end

  describe "when marking a value as placed in row b" do
    # puts "\nBEFORE"
    # puts "row a:"
    # puts row_a.inspect
    # puts "row b:"
    # puts row_b.inspect

    row_b.place(1)

    # puts "\nAFTER"
    # puts "row a:"
    # puts row_a.inspect
    # puts "row b:"
    # puts row_b.inspect

    it "should now have the value" do
      row_b.has?(1).should be_true
    end

    it "should eliminate the value as a candidate from all its cells" do
      row_b.each_cell { |cell| cell.candidates[1].should be_false }
    end

    it "should not affect row a’s has map" do
      row_a.has?(1).should be_false
    end

    it "should not eliminate the value as a candidate from row a’s cells" do
      row_a.each_cell { |cell| cell.candidates[1].should be_true }
    end
  end
end
