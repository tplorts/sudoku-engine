require "bit_array"

struct BitArray
  alias Word = UInt32

  WORD_BYTE_SIZE = sizeof(Word)
  WORD_BIT_SIZE  = 8 * WORD_BYTE_SIZE

  def initialize(@size, initial : Bool = false)
    value = initial ? Word::MAX : Word::MIN
    @bits = Pointer(Word).malloc(malloc_size, value)

    if initial
      # Set all unused bits to 0 so that comparison can still use memcmp
      last_bit_index = size - 1
      last_word_index, last_subbit_index = last_bit_index.divmod(WORD_BIT_SIZE)
      bits_used_in_last_word = last_subbit_index + 1
      @bits[last_word_index] &= ~(Word::MAX << bits_used_in_last_word)
    end
  end

  def ==(other : BitArray)
    return size == other.size &&
      LibC.memcmp(@bits, other.@bits, malloc_size * WORD_BYTE_SIZE) == 0
    # The built-in implementation does not include `* sizeof(UInt32)`s
  end
end
