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

    def print_grid
      puts @sudoku.to_s if @debug_output_enabled
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

        exhaustively_fill_determined_cells

        placements_made = initial_empty_count - empty_count

        validate

        # break if empty_count == 0
        # (1..N).each do |n|
        #   place_throughout(n)
        #   break if empty_count == 0
        # end

        iterations += 1
      end

      raise "Failed to solve" if empty_count > 0
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

        puts "Filled #{placements_made} cells" if @debug_output_enabled
        print_grid
        validate
      end
    end

    def fill_determined_cells
      @sudoku.each_cell_with_position do |cell, position|
        @sudoku.place(cell.candidate, position) if cell.determined?
      end
    end

    # Searches for blocks in which there is only one candidate position for value
    # and places value there if any such fully determined placements are found.
    def place_throughout(value : Int)
      @sudoku.each_block do |block|
        candidate_positions = find_candidate_positions(value, block)
        @sudoku.place(value, candidate_positions[0]) if candidate_positions.size == 1
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
  end
end
