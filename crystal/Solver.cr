require "./State"
require "./Sections"

module Sudoku
  class Solver
    @@recursions = 0

    getter state : State

    protected property debug_output_enabled : Bool
    protected property debug_validation_enabled : Bool

    protected property search_depth : Int32

    def initialize(filename : String,
                   debug_output_enabled : Bool = false,
                   debug_validation_enabled : Bool = false)
      @debug_output_enabled = debug_output_enabled
      @debug_validation_enabled = debug_validation_enabled

      @search_depth = 0

      @state = State.new
      @state.load_from_file(filename)
    end

    def initialize(source : Solver)
      @@recursions += 1

      @debug_output_enabled = source.debug_output_enabled
      @debug_validation_enabled = source.debug_validation_enabled

      @search_depth = source.search_depth + 1

      @state = State.new(source.state)
    end

    def debug(stuff)
      if @debug_output_enabled
        indentation = "> " * @search_depth

        puts stuff
          .split('\n')
          .map { |line| indentation + line }
          .join('\n')
      end
    end

    def empty_count
      @state.empty_cell_count
    end

    def complete?
      empty_count == 0
    end

    def valid?
      @state.valid?
    end

    def validate
      raise InvalidError.new if @debug_validation_enabled && !valid?
    end

    def solve
      until_complete_or_stuck do
        solve_determined
        eliminate_candidates_by_partial_determination unless complete?
      end

      complete? ? self : try_to_solve
    end

    def try_to_solve
      @state.each_cell_with_position do |cell, position|
        next if cell.occupied?

        cell.candidate_values.each do |candidate_value|
          child = Solver.new(self)
          child.state.place(candidate_value, position)
          begin
            child.solve
          rescue error : InvalidError
          end
          return child if child.complete?
        end
      end

      nil
    end

    def solve_determined
      until_complete_or_stuck do
        exhaustively_fill_determined_cells
        exhaustively_fill_determined_positions
      end
    end

    # Repeatedly searches for cells which are fully determined by their own
    # list of candidate values.  Places the value when the cell is fully
    # determined.  Stops repeating when no placements were made over the course
    # of a single iteration to check the entire sudoku.
    def exhaustively_fill_determined_cells
      until_complete_or_stuck { fill_determined_cells }
    end

    def fill_determined_cells
      @state.each_cell_with_position do |cell, position|
        @state.place(cell.first_candidate, position) if cell.determined?
      end
    end

    def exhaustively_fill_determined_positions
      until_complete_or_stuck { fill_determined_positions }
    end

    # Searches for blocks in which there is only one candidate position for a value
    # and places the value there if any such fully determined positions are found.
    def fill_determined_positions
      (1..N).each do |value|
        @state.each_block do |block|
          candidate_positions = find_candidate_positions(value, block)
          @state.place(value, candidate_positions[0]) if candidate_positions.size == 1
        end
      end
    end

    # Finds the positions of all cells into which value could be placed
    def find_candidate_positions(value : Int, block : Block) : Array(Position)
      candidates = Array(Position).new

      # Rule out immediately if this Block already has the value
      return candidates if block.has?(value)

      block.each_cell_with_position do |cell, position|
        # Skip checking whether the Block has value here since we
        # already did that above, before looping through each cell
        next if cell.occupied? ||
                @state.row(position).has?(value) ||
                @state.column(position).has?(value)

        candidates << position
      end

      return candidates
    end

    def eliminate_candidates_by_partial_determination
      @state.each_block do |block|
        (1..N).each do |value|
          determined_row_index, determined_column_index = find_determined_row_column_in_block(value, block)

          if determined_row_index && determined_column_index
            @state.place(value, {determined_row_index, determined_column_index})
          elsif determined_row_index
            row = @state.row(determined_row_index)
            eliminate_candidate_in_section_except_in_block(value, row, block)
          elsif determined_column_index
            column = @state.column(determined_column_index)
            eliminate_candidate_in_section_except_in_block(value, column, block)
          end
        end
      end
    end

    def find_determined_row_column_in_block(value : CellValue, block : Block)
      # value can go nowhere in this block if already in the block
      return {nil, nil} if block.has?(value)

      candidate_rows = Set(Int32).new
      candidate_columns = Set(Int32).new

      # Find the set of rows/columns within this block which could contain
      # value.
      block.each_cell_with_position do |cell, (row_index, column_index)|
        if cell.candidate?(value)
          candidate_rows.add(row_index)
          candidate_columns.add(column_index)
        end
      end

      # And now, if there is only one row that could contain value in this
      # block, then we can deduce that value cannot be placed in that row
      # in the two blocks horizontally adjacent to this block.
      # And likewise, for columns and vertically adjacent blocks.
      determined_row_index = candidate_rows.size == 1 ? candidate_rows.to_a[0] : nil
      determined_column_index = candidate_columns.size == 1 ? candidate_columns.to_a[0] : nil

      {determined_row_index, determined_column_index}
    end

    def eliminate_candidate_in_section_except_in_block(candidate_value : CellValue,
                                                       section : LinearSection,
                                                       block : Block)
      # If some value will definitely go in a particular row within a block
      # but is not yet fully determined, then the two horizontally adjacent
      # blocks can eliminate that value as a candidate from all of their cells
      # in this row.
      # LIKEWISE FOR A COLUMN:
      # If some value will definitely go in a particular column within a block
      # but is not yet fully determined, then the two vertically adjacent
      # blocks can eliminate that value as a candidate from all of their cells
      # in this column.
      section.each_cell_with_position do |cell, position|
        unless block.includes?(position)
          cell.eliminate_candidate(candidate_value)
        end
      end
    end

    def until_complete_or_stuck
      stuck? = false
      until complete? || stuck?
        initial_empty_count = empty_count
        yield
        stuck? = empty_count == initial_empty_count
      end
    end
  end
end
