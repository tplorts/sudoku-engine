require "spec"
require "../State"

include Sudoku

describe State do
  sudoku_a = State.new
  sudoku_a.load_from_file("../puzzles/20190220a.sudoku")

  describe "row valid?" do
    N.times do |row_index|
      it "should report that row #{row_index} is valid" do
        sudoku_a.row(row_index).valid?.should be_true
      end
    end
  end

  describe "column valid?" do
    N.times do |column_index|
      it "should report that column #{column_index} is valid" do
        sudoku_a.column(column_index).valid?.should be_true
      end
    end
  end

  describe "block valid?" do
    (0...B).each do |block_row_index|
      (0...B).each do |block_column_index|
        it "should report that block (#{block_row_index}, #{block_column_index}) is valid" do
          sudoku_a.block(block_row_index, block_column_index).valid?.should be_true
        end
      end
    end
  end

  describe "cell valid?" do
    sudoku_a.each_cell_with_position do |cell, position|
      it "should report that cell #{position} is valid" do
        cell.valid?.should be_true
      end
    end
  end

  describe "cell valid?" do
    it "should report that the whole sudoku state is valid" do
      sudoku_a.valid?.should be_true
    end
  end
end
