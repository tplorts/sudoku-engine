require "./State"

module Sudoku
  class Solver
    protected property sudoku : State

    protected property debug_output_enabled : Bool
    protected property validation_enabled : Bool

    def initialize(filename, debug_output_enabled : Bool = false, validation_enabled : Bool = false)
      @debug_output_enabled = debug_output_enabled
      @validation_enabled = validation_enabled

      @sudoku = State.new
      @sudoku.load_from_file(filename)
    end

    def debug(stuff)
      puts stuff if @debug_output_enabled
    end

    def print_grid
      debug @sudoku.to_s
    end

    def empty_count
      @sudoku.empty_cell_count
    end

    def complete?
      empty_count == 0
    end

    def valid?
      @sudoku.valid?
    end

    def validate
      raise "SUDOKU INVALID" if @validation_enabled && !valid?
    end

    def solve
      iterations = 0
      placements_made = nil

      until complete? || placements_made == 0
        initial_empty_count = empty_count

        solve_determined
        eliminate_candidates_by_partially_determined unless complete?

        placements_made = initial_empty_count - empty_count
        debug "major iteration #{iterations}: #{placements_made} placements"
        iterations += 1
      end

      raise "Failed to solve" if empty_count > 0
    end

    def solve_determined
      iterations = 0
      placements_made = nil

      until complete? || placements_made == 0
        initial_empty_count = empty_count

        exhaustively_fill_determined_cells

        validate

        exhaustively_fill_determined_positions

        validate

        placements_made = initial_empty_count - empty_count
        debug "determined iteration #{iterations}: #{placements_made} placements"
        iterations += 1
      end
    end

    # Repeatedly searches for cells which are fully determined by their own
    # list of candidate values.  Places the value when the cell is fully
    # determined.  Stops repeating when no placements were made over the course
    # of a single iteration to check the entire sudoku.
    def exhaustively_fill_determined_cells
      placements_made = nil

      until complete? || placements_made == 0
        initial_empty_count = empty_count

        fill_determined_cells

        placements_made = initial_empty_count - empty_count

        debug "Filled #{placements_made} cells" if @debug_output_enabled
        print_grid if placements_made > 0
        validate
      end
    end

    def fill_determined_cells
      @sudoku.each_cell_with_position do |cell, position|
        @sudoku.place(cell.candidate, position) if cell.determined?
      end
    end

    def exhaustively_fill_determined_positions
      placements_made = nil

      until complete? || placements_made == 0
        initial_empty_count = empty_count

        fill_determined_positions

        placements_made = initial_empty_count - empty_count

        debug "Filled #{placements_made} positions" if @debug_output_enabled
        print_grid if placements_made > 0
        validate
      end
    end

    # Searches for blocks in which there is only one candidate position for a value
    # and places the value there if any such fully determined positions are found.
    def fill_determined_positions
      (1..N).each do |value|
        @sudoku.each_block do |block|
          candidate_positions = find_candidate_positions(value, block)
          @sudoku.place(value, candidate_positions[0]) if candidate_positions.size == 1
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
                @sudoku.row(position).has?(value) ||
                @sudoku.column(position).has?(value)

        candidates << position
      end

      return candidates
    end

    def eliminate_candidates_by_partially_determined
      @sudoku.each_block do |block|
        (1..N).each do |value|
          # only consider values not yet placed in this block
          next if block.has?(value)

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
          row_determined = candidate_rows.size == 1
          column_determined = candidate_columns.size == 1

          determined_row_index = candidate_rows.to_a[0]
          determined_column_index = candidate_columns.to_a[0]

          if row_determined && column_determined
            @sudoku.place(value, {determined_row_index, determined_column_index})
            next # next value in this block
          end

          if row_determined
            row = @sudoku.row(determined_row_index)

            debug "Eliminating #{value} from row #{determined_row_index} except in columns #{block.column_range}"

            # Since value will definitely go in this row within this block,
            # the two horizontally adjacent blocks can eliminate value as a
            # candidate from all of their cells in this row.
            row.each_cell_with_position do |cell, (_, column_index)|
              unless block.column_range.includes?(column_index)
                debug "   > eliminate #{value} from (#{determined_row_index},#{column_index})" if cell.candidate?(value)
              end
              cell.eliminate_candidate(value) unless block.column_range.includes?(column_index)
            end
          end

          if column_determined
            column = @sudoku.column(determined_column_index)

            debug "Eliminating #{value} from column #{determined_column_index} except in rows #{block.row_range}"

            # Since value will definitely go in this column within this block,
            # the two vertically adjacent blocks can eliminate value as a
            # candidate from all of their cells in this column.
            column.each_cell_with_position do |cell, (row_index)|
              unless block.row_range.includes?(row_index)
                debug "   > eliminate #{value} from (#{row_index},#{determined_column_index})" if cell.candidate?(value)
              end
              cell.eliminate_candidate(value) unless block.row_range.includes?(row_index)
            end
          end
        end
      end
    end
  end
end
