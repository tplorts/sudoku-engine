module Sudoku
  B = 3
  N = B ** 2

  alias IndexRange = Range(Int32, Int32)
  alias CellValue = Int32
  alias CellOccupant = CellValue | Nil
  alias Position = {Int32, Int32}

  class InvalidError < Exception
    def to_s
      "generally invalid sudoku error"
    end
  end
end
