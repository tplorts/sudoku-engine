require "spec"
require "../State"

# Printed version of 20190220a for reference:
#
# -------------------------------------
# | 7 | 9 | 1 |   |   | 2 |   | 4 | 5 |
# -------------------------------------
# |   |   | 3 | 4 |   |   |   | 2 | 9 |
# -------------------------------------
# |   |   |   | 1 | 9 | 5 |   | 8 |   |
# -------------------------------------
# | 6 | 3 |   |   |   | 9 |   | 1 | 8 |
# -------------------------------------
# |   |   | 7 | 3 |   |   | 2 |   |   |
# -------------------------------------
# |   | 5 |   |   | 1 | 4 |   | 3 |   |
# -------------------------------------
# |   | 7 |   |   |   |   | 5 |   | 2 |
# -------------------------------------
# | 4 |   | 9 |   | 5 | 3 | 8 |   |   |
# -------------------------------------
# | 1 |   |   | 2 | 8 |   | 4 |   |   |
# -------------------------------------

def get_number_table(file_lines : Array(String))
  file_lines.map do |line|
    line
      .split("")
      .map { |ch| ch.to_i? }
  end
end

describe State do
  filename = "../puzzles/20190220a.sudoku"
  sudoku_a = State.new
  sudoku_a.load_from_file(filename)
  file_lines = File.read_lines(filename)

  number_table = get_number_table(file_lines)

  describe "row has?" do
    row_sets = number_table.map { |row| row.compact.to_set }

    N.times do |i|
      this_row = sudoku_a.row(i)
      numbers_in_row = row_sets[i]

      (1..N).each do |n|
        in_row? = numbers_in_row.includes? n

        it "should report that #{n} is #{in_row? ? "present" : "absent"} in row #{i}" do
          this_row.has?(n).should eq in_row?
        end
      end
    end
  end

  describe "column has?" do
    column_sets = number_table.transpose.map { |row| row.compact.to_set }

    N.times do |i|
      this_column = sudoku_a.column(i)
      numbers_in_column = column_sets[i]

      (1..N).each do |n|
        in_column? = numbers_in_column.includes? n

        it "should report that #{n} is #{in_column? ? "present" : "absent"} in column #{i}" do
          this_column.has?(n).should eq in_column?
        end
      end
    end
  end

  describe "block has?" do
    (0...B).each do |sri|
      (0...B).each do |sci|
        this_block = sudoku_a.block(sri, sci)

        numbers_in_block = number_table[B*sri, B]
          .map { |row| row[B*sci, B] }
          .flatten
          .compact
          .to_set

        (1..N).each do |n|
          present? = numbers_in_block.includes? n

          it "should report that #{n} is #{present? ? "present" : "absent"} in block (#{sri}, #{sci})" do
            this_block.has?(n).should eq present?
          end
        end
      end
    end
  end
end
