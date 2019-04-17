require "./core"
require "./Cell"

module Sudoku
  class Grid
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
      row_strings = @table.map { |table_row| "| #{table_row.map(&.to_s).join(" | ")} |" }
      h_line = "\n#{"-" * row_strings[0].size}\n"
      "#{h_line}#{row_strings.join(h_line)}#{h_line}".strip
    end

    def to_verbose_s
      row_strings = @table.map do |table_row|
        inner_row_string = table_row
          .map(&.to_verbose_s)
          .join(" | ")
        "| #{inner_row_string} |"
      end
      h_line = "\n#{"-" * row_strings[0].size}\n"
      "#{h_line}#{row_strings.join(h_line)}#{h_line}"
    end

    def valid?
      @table.all?(&.all?(&.valid?))
    end
  end
end
