require "./BitArray"
require "./core"
require "./Grid"

module Sudoku
  abstract class Section
    getter has_map : BitArray

    def initialize(@grid : Grid)
      @has_map = BitArray.new(N + 1)
    end

    def initialize(@grid : Grid, source : Section)
      @has_map = source.has_map[0..N]
    end

    def each_position(&block)
    end

    def each_cell
      each_position { |position| yield @grid[position] }
    end

    def each_cell_with_position
      each_position { |position| yield @grid[position], position }
    end

    def has?(value : CellValue)
      @has_map[value]
    end

    def place(value : CellValue)
      raise "Hey! #{value} isn’t supposed to go in this section!" if has?(value)
      @has_map[value] = true
      each_cell(&.eliminate_candidate(value))
    end

    def valid?
      seen = BitArray.new(N + 1)
      each_cell do |cell|
        value = cell.occupant
        next if !value

        return false if seen[value]
        seen[value] = true
      end
      return true
    end
  end

  abstract class LinearSection < Section
    getter index : Int32

    def initialize(@grid : Grid, @index : Int32)
      super(@grid)
    end

    def initialize(@grid : Grid, source : LinearSection)
      super
      @index = source.index
    end
  end

  class Row < LinearSection
    def each_position
      (0...N).each { |column_index| yield ({@index, column_index}) }
    end
  end

  class Column < LinearSection
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

    def initialize(@grid : Grid, block_row_index : Int, block_column_index : Int)
      super(@grid)

      @row_range = make_index_range(block_row_index)
      @column_range = make_index_range(block_column_index)
    end

    def initialize(@grid : Grid, source : Block)
      super

      @row_range = source.row_range
      @column_range = source.column_range
    end

    def each_position
      @row_range.each do |row_index|
        @column_range.each do |column_index|
          yield ({row_index, column_index})
        end
      end
    end

    def includes?(position : Position)
      @row_range.includes?(position[0]) && @column_range.includes?(position[1])
    end
  end
end
