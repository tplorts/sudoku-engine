require "./BitArray"
require "./core"

module Sudoku
  class InvalidCellError < InvalidError
    getter cell : Cell

    def initialize(@cell : Cell)
    end

    def to_s
      "invalid cell: #{cell.inspect}"
    end
  end

  class CellContradiction < InvalidCellError
    def to_s
      "cell contradiction in #{cell.inspect}"
    end
  end

  class PlacementConflict < InvalidCellError
    def to_s
      "placement conflict in #{cell.inspect}"
    end
  end

  class InvalidPlacement < InvalidCellError
    def to_s
      "invalid placement in #{cell.inspect}"
    end
  end

  ALL_CANDIDATES            = BitArray.new(N + 1, true)
  NO_CANDIDATES_NO_OCCUPANT = BitArray.new(N + 1, false)
  NO_CANDIDATES_NO_OCCUPANT[0] = true

  class Cell
    getter occupant : CellOccupant
    getter candidates : BitArray

    def initialize
      @occupant = nil
      # Initially unoccupied; all possible numbers are candidates.
      @candidates = BitArray.new(N + 1, unoccupied?)
    end

    def initialize(source : Cell)
      @occupant = source.occupant
      @candidates = source.candidates[0..N]
    end

    def place(n : CellValue)
      raise PlacementConflict.new(self) if occupied?
      raise InvalidPlacement.new(self) if !candidate?(n)

      @occupant = n
      @candidates = BitArray.new(N + 1, false)
    end

    def occupied?
      !unoccupied?
    end

    def unoccupied?
      @occupant.nil?
    end

    def eliminate_candidate(n : CellValue)
      @candidates[n] = false
      raise CellContradiction.new(self) if @candidates == NO_CANDIDATES_NO_OCCUPANT
    end

    def candidate?(n : CellValue)
      unoccupied? && @candidates[n]
    end

    def determined?
      unoccupied? && candidate_count == 1
    end

    def candidate_count
      (1..N).count { |n| @candidates[n] }
    end

    def candidate_values
      (1..N).select { |n| @candidates[n] }
    end

    def first_candidate
      (1..N).find { |n| candidate?(n) } || raise CellContradiction.new(self)
    end

    def has_any_candidates?
      (1..N).any? { |n| @candidates[n] }
    end

    def valid?
      has_any_candidates? == unoccupied?
    end

    def to_s
      occupant ? occupant.to_s : " "
    end

    def to_candidates_s
      (1..N)
        .map { |n| candidate?(n) ? n.to_s : " " }
        .join("")
    end

    def to_verbose_s
      occupied? ? "░░░ #{occupant} ░░░" : to_candidates_s
    end
  end
end
