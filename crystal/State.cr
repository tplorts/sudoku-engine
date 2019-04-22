require "file"
require "./core"
require "./Cell"
require "./Grid"
require "./Sections"

module Sudoku
  class State
    getter empty_cell_count : Int32

    getter grid : Grid

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

    def initialize(source : State)
      @grid = Grid.new(source.grid)
      @empty_cell_count = source.empty_cell_count

      @rows = source.rows.map { |source_row| Row.new(@grid, source_row) }
      @columns = source.columns.map { |source_column| Column.new(@grid, source_column) }
      @blocks = source.blocks.map(&.map { |source_block| Block.new(@grid, source_block) })
    end

    def load_from_file(filename : String)
      # Forms a simple 2D array of numbers or nil for empty
      raw_table = File.read_lines(filename).map(&.split("").map(&.to_i?))

      @grid.each_position do |position|
        n = raw_table[position[0]][position[1]]
        place(n, position) if n
      end
    end

    def each_cell_with_position
      @grid.each_cell_with_position do |cell, position|
        yield cell, position
      end
    end

    def each_section
      @rows.each { |row| yield row }
      @columns.each { |column| yield column }
      each_block { |block| yield block }
    end

    def each_block
      @blocks.each do |block_row|
        block_row.each do |block|
          yield block
        end
      end
    end

    def sections_for_position(position : Position)
      [row(position), column(position), block(position)]
    end

    def place(n : Int, position : Position)
      @grid[position].place(n)

      sections_for_position(position).each(&.place(n))

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
        @blocks.all?(&.all?(&.valid?)) &&
        all_cell_states_agree_with_section_states
    end

    def all_cell_states_agree_with_section_states
      @grid.all_cells? do |cell, position|
        cells_sections = sections_for_position(position)
        occupant = cell.occupant
        if occupant
          # Make sure that this cell’s row, column, & block all know that they
          # contain this value (the value in this cell)
          cells_sections.all?(&.has?(occupant))
        else
          (1..N).all? do |n|
            # n should only be a candidate value for this cell if none of its
            # sections (row/column/block) contain n.
            !cell.candidate?(n) || cells_sections.none?(&.has?(n))
            # Note, however, that n may have already been eliminated as a
            # candidate value for this cell even though none of this cell’s
            # sections yet contain n.  This possibility arises from cell-value
            # candidate elimination by partial determination.
          end
        end
      end
    end
  end
end
