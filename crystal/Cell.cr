require "bit_array"
require "./core"

module Sudoku
  class Cell
    getter occupant : CellOccupant
    protected property candidates : BitArray

    def initialize(@occupant = nil)
      # If initially occupied, there are no candidates.
      # If initially unoccupied, all possible numbers are candidates.
      @candidates = BitArray.new(N + 1, !occupied?)
    end

    def place(value : CellValue)
      raise "Hey! I’m already occupied!" if occupied?
      raise "Hey! #{value} isn’t supposed to go here!" if !candidate?(value)
      @occupant = value
      @candidates = BitArray.new(N + 1, false)
    end

    def occupied?
      !unoccupied?
    end

    def unoccupied?
      @occupant.nil?
    end

    def eliminate_candidate(value : CellValue)
      @candidates[value] = false
    end

    def candidate?(value : CellValue)
      unoccupied? && @candidates[value]
    end

    def determined?
      unoccupied? && candidate_count == 1
    end

    private def candidate_count
      (1..N).count { |n| candidate?(n) }
    end

    def candidate
      (1..N).find { |n| candidate?(n) } || raise "no candidate!"
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
      occupied? ? "=== #{occupant} ===" : to_candidates_s
    end
  end
end
