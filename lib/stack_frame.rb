class StackFrame
  attr_reader :saved_register_table, :field_offset_table, :frame_offset_table

  class SaveRegistersMips
    attr_reader :register_count

    def initialize(register_count)
      @register_count = register_count
    end

    def to_s
      ([ "addi $sp, $sp, #{register_count * -4}" ] +
       register_count
       .times
       .map {|n| n > 7 ? "sw $t#{n - 7 + 2}, #{4 * n}($sp)" : "sw $s#{n}, #{4 * n}($sp)" })
       .join("\n")
    end
  end

  class RestoreRegistersMips
    attr_reader :register_count

    def initialize(register_count)
      @register_count = register_count
    end

    def to_s
      (register_count
       .times
       .map {|n| n > 7 ? "lw $t#{n - 7 + 2}, #{4 * n}($sp)" : "lw $s#{n}, #{4 * n}($sp)" } +
       [ "addi $sp, $sp, #{register_count * 4}" ])
       .join("\n")
    end
  end

  def initialize(previous=nil, symbol_dict=Hash.new)
    @saved_register_table = Hash.new
    @register_index = -1

    @field_offset_table = Hash.new
    @field_index = -1

    @frame_offset_table = Hash.new
    @frame_index = 0
    # Other things
    @previous = previous
    @size = symbol_dict.length
    @symbol_list = symbol_dict.keys
  end

  def set_next_register(id)
    @register_index = @register_index + 1
    saved_register_table[id] = @register_index
    saved_register_from(@register_index)
  end

  def get_register(id)
    saved_register_from(saved_register_table[id])
  end

  def saved_register_from(register_index)
    if register_index > 7
      "$t#{register_index - 7 + 2}"
    else
      "$s#{register_index}"
    end
  end

  def has_register_for?(id)
    saved_register_table.has_key?(id)
  end

  def register_count
    @register_index + 1
  end

  def save_registers_mips
    SaveRegistersMips.new(register_count)
  end

  def restore_registers_mips
    RestoreRegistersMips.new(register_count)
  end

  def add_parameter(id)
    @frame_index = @frame_index + 1
    frame_offset_table[id] = @frame_index * 4
  end

  def frame_offset(id)
    frame_offset_table[id]
  end

  def has_frame_offset_for?(id)
    frame_offset_table.has_key?(id)
  end

  def add_field(id)
    @field_index = @field_index + 1
    field_offset_table[id] = @field_index * 4
  end

  def field_offset(id)
    field_offset_table[id]
  end

  def has_field_offset_for?(id)
    field_offset_table.has_key?(id)
  end

  # # returns the offset from the beginning of this frame
  # # to get to the given symbol
  # def offset sym
  #   @symbol_list.find_index sym or (@previous and @previous.reverse_offset sym)
  # end

  # # to be called from another stack frame while searching into previous frames
  # def reverse_offset sym
  #   val = self.offset(sym)
  #   val - @size if val
  # end
end
