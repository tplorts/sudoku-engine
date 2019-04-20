require "./core"
require "./Cell"
require "./GridFormatter"

module Sudoku
  class Grid
    @@verbose_formatter = VerboseGridFormatter.new
    @@standard_formatter = StandardGridFormatter.new

    protected property table : Array(Array(Cell))

    def initialize
      @table = Array.new(N) { |r| Array.new(N) { |c| Cell.new } }
    end

    def cell(position : Position)
      @table[position[0]][position[1]]
    end

    def [](position : Position)
      cell(position)
    end

    def each_position
      (0...N).each do |row_index|
        (0...N).each do |column_index|
          yield ({row_index, column_index})
        end
      end
    end

    def each_cell_with_position
      each_position { |position| yield cell(position), position }
    end

    def all_cells?
      each_cell_with_position do |cell, position|
        return false unless yield(cell, position)
      end
      true
    end

    def to_s
      @@standard_formatter.stringify(@table)
    end

    def to_verbose_s
      @@verbose_formatter.stringify(@table)
    end

    def valid?
      @table.all?(&.all?(&.valid?))
    end
  end
end
