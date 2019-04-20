require "./core"
require "./Cell"

module Sudoku
  abstract class GridFormatter
    def initialize
      # 2 spaces on either side of each cell
      cell_width = cell_content_width + 2

      n_cell_borders = ["═" * cell_width] * N

      @top = "╔#{n_cell_borders.join("╦")}╗"
      @bottom = "╚#{n_cell_borders.join("╩")}╝"
      @middle_major = "\n╠#{n_cell_borders.join("╬")}╣\n"
      @middle_minor = "\n╠#{([(["─" * cell_width] * B).join("┼")] * B).join("╬")}╣\n"
    end

    abstract def cell_content_width

    abstract def stringify_cell(cell : Cell)

    def stringify(table : Array(Array(Cell)))
      row_strings = table.map do |table_row|
        inner_row_string = table_row
          .each_slice(B)
          .map(&.map { |cell| stringify_cell(cell) }.join(" │ "))
          .join(" ║ ")
        "║ #{inner_row_string} ║"
      end

      [
        @top,
        row_strings
          .each_slice(B)
          .map(&.join(@middle_minor))
          .join(@middle_major),
        @bottom,
      ]
        .join("\n")
    end
  end

  class StandardGridFormatter < GridFormatter
    def stringify_cell(cell : Cell)
      cell.to_s
    end

    def cell_content_width
      1
    end
  end

  class VerboseGridFormatter < GridFormatter
    def stringify_cell(cell : Cell)
      cell.to_verbose_s
    end

    def cell_content_width
      N
    end
  end
end
