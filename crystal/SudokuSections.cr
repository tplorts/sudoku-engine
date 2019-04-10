require "bit_array"
require "./core"
require "./SudokuGrid"

private abstract class Section
  def initialize(@grid : SudokuGrid)
    @has = BitArray.new(N + 1)
  end

  abstract def each_position

  def each_cell
    each_position { |position| yield @grid[position] }
  end

  def each_cell_with_position
    each_position { |position| yield @grid[position], position }
  end

  def has?(value : CellValue)
    @has[value]
  end

  def place(value : CellValue)
    @has[value] = true
    each_cell(&.eliminate_candidate(value))
  end

  def valid?
    seen = BitArray.new(N + 1)
    each_cell do |cell|
      return false if !(n = cell.occupant).nil? && seen[n]
    end
    return true
  end
end

class Row < Section
  def initialize(@grid : SudokuGrid, @index : Int32)
    super(@grid)
  end

  def each_position
    (0...N).each { |column_index| yield ({@index, column_index}) }
  end
end

class Column < Section
  def initialize(@grid : SudokuGrid, @index : Int32)
    super(@grid)
  end

  def each_position
    (0...N).each { |row_index| yield ({row_index, @index}) }
  end
end

class Block < Section
  getter row_range : IndexRange
  getter column_range : IndexRange

  private def make_index_range(block_index : Int)
    (B * block_index)...(B * (block_index + 1))
  end

  def initialize(@grid : SudokuGrid, block_row_index : Int, block_column_index : Int)
    super(@grid)

    @row_range = make_index_range(block_row_index)
    @column_range = make_index_range(block_column_index)
  end

  def each_position
    @row_range.each do |row_index|
      @column_range.each do |column_index|
        yield ({row_index, column_index})
      end
    end
  end
end
