require "spec"
require "../BitArray"
# require "bit_array"

describe "BitArray" do
  describe "exactly 1 byte long" do
    ba_0 = BitArray.new(8)
    ba_1 = BitArray.new(8)

    it "should be equal: #{ba_0} == #{ba_1}" do
      ba_0.should eq ba_1
    end

    ba_1[7] = true

    it "should not be equal: #{ba_0} != #{ba_1}" do
      ba_0.should_not eq ba_1
    end
  end

  describe "more than 1 byte long" do
    ba_0 = BitArray.new(9)
    ba_1 = BitArray.new(9)

    it "should be equal: #{ba_0} == #{ba_1}" do
      ba_0.should eq ba_1
    end

    # Set the first bit **after** byte 0
    ba_1[8] = true

    # Byte 0 is still the same in both; they only differ in the 9th bit
    # (first bit of byte 1)

    it "should not be equal: #{ba_0} != #{ba_1}" do
      # Fails.
      # Guessing that it thinks they're equal because it only compares one byte
      ba_0.should_not eq ba_1
    end
  end

  # All of these (except 32) will fail without the overridden initialize method
  # which ensures that all unused bits are 0.  The 32-bit test passes because it
  # has no unused bits.
  test_equality_given_opposite_initial_values(9)
  test_equality_given_opposite_initial_values(31)
  test_equality_given_opposite_initial_values(32)
  test_equality_given_opposite_initial_values(33)
  test_equality_given_opposite_initial_values(50)
end

def test_equality_given_opposite_initial_values(size : Int)
  describe "equate two #{size}-bit arrays with different initial values" do
    ba_0 = BitArray.new(size, false)
    ba_1 = BitArray.new(size, true)

    it "should start as unequal: #{ba_0} != #{ba_1}" do
      ba_0.should_not eq ba_1
    end

    (0...size).each { |i| ba_0[i] = true }

    it "should now be equal: #{ba_0} == #{ba_1}" do
      ba_0.should eq ba_1
    end
  end
end
