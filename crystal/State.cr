require "file"
require "bit_array"
require "./core"
require "./Cell"
require "./Grid"
require "./Sections"

module Sudoku
  class State
    getter empty_cell_count : Int32

    protected property grid : Grid

    protected property rows : Array(Row)
    protected property columns : Array(Column)
    protected property blocks : Array(Array(Block))

    def initialize
      @grid = Grid.new

      @empty_cell_count = N * N

      @rows = (0...N).map { |i| Row.new(@grid, i) }
      @columns = (0...N).map { |i| Column.new(@grid, i) }
      @blocks = (0...B).map { |br| (0...B).map { |bc| Block.new(@grid, br, bc) } }
    end

    def load_from_file(filename : String)
      # Forms a simple 2D array of numbers or nil for empty
      raw_table = File.read_lines(filename).map(&.split("").map(&.to_i?))

      @grid.each_position do |position|
        value = raw_table[position[0]][position[1]]
        place(value, position) if value
      end
    end

    def each_cell_with_position
      @grid.each_cell_with_position do |cell, position|
        yield cell, position
      end
    end

    def each_block
      @blocks.each do |block_row|
        block_row.each do |block|
          yield block
        end
      end
    end

    def to_s
      @grid.to_s
    end

    def place(value : Int, position : Position)
      @grid[position].place(value)

      row(position).place(value)
      column(position).place(value)
      block(position).place(value)

      @empty_cell_count -= 1
    end

    def row(index : Int)
      @rows[index]
    end

    def row(position : Position)
      @rows[position[0]]
    end

    def column(index : Int)
      @columns[index]
    end

    def column(position : Position)
      @columns[position[1]]
    end

    def block(block_row_index : Int, block_column_index : Int)
      @blocks[block_row_index][block_column_index]
    end

    def block(position : Position)
      @blocks[position[0] / B][position[1] / B]
    end

    def valid?
      @grid.valid? &&
        @rows.all?(&.valid?) &&
        @columns.all?(&.valid?) &&
        @blocks.all?(&.all?(&.valid?))
    end
  end
end
