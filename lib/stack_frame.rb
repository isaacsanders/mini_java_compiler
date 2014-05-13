class StackFrame
  attr_reader :size

  def initialize(previous, symbol_dict)
    @previous = previous
    @size = symbol_dict.length
    @symbol_list = symbol_dict.keys
  end

  # returns the offset from the beginning of this frame
  # to get to the given symbol
  def offset sym
    @symbol_list.find_index sym or (@previous and @previous.reverse_offset sym)
  end

  # to be called from another stack frame while searching into previous frames
  def reverse_offset sym
    val = self.offset(sym)
    val - @size if val
  end
end
