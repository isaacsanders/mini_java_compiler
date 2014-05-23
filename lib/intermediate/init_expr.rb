require_relative "expression"

module Intermediate
  class InitExpr < Expression
    attr_reader :parent_class_id, :symbol_table

    def initialize(parent_class_id)
      @parent_class_id = parent_class_id
    end

    def to_type
      parent_class_id
    end

    def parent_class
      symbol_table.get_class(parent_class_id).type
    end

    def to_mips(stack_frame)
      size = parent_class.byte_size
      [
        "addi $sp, $sp, -4 # Push 'this' before syscall",
        "sw $a0, 0($sp)",
        "li $v0, 9",
        "li $a0, #{size}",
        "syscall # Initialize #{parent_class.name}",
        "or $t0, $v0, $v0",
        "lw $a0, 0($sp)",
        "addi $sp, $sp, 4 # Pop 'this' after syscall"
      ]
    end

    def check_types(errors)
    end
  end
end
