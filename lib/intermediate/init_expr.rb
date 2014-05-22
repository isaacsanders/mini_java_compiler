require_relative "expression"

module Intermediate
  class InitExpr < Expression
    attr_reader :parent_class_name, :symbol_table

    def initialize(parent_class_name)
      @parent_class_name = parent_class_name
    end

    def to_type
      parent_class_name
    end

    def parent_class
      symbol_table.get_class(parent_class_name).type
    end

    def to_mips(stack_frame)
      size = parent_class.byte_size
      [
        "li $v0, 9",
        "li $a0, #{size}",
        "syscall",
        "or $t0, $v0, $v0"
      ]
    end

    def check_types(errors)
    end
  end
end
