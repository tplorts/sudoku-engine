require "spec"
require "../../Grid"

include Sudoku

grid_a = Grid.new

describe "Grid clone" do
  grid_b = Grid.new(grid_a)

  it "should not be the same grid" do
    grid_b.should_not be grid_a
  end

  grid_a.each_cell_with_position do |cell_a, position|
    describe "cell at #{position}" do
      cell_b = grid_b[position]

      it "should not be the same cell" do
        cell_b.should_not be cell_a
      end
    end
  end
end
