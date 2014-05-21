require_relative "statement"
require_relative "errors"
require_relative "../terminals"

module Intermediate
  class PrintlnStatement < Statement
    include Terminals

    attr_reader :expr

    def initialize(expr)
      @expr = expr # int type
    end

    def init_st(parent)
      super
      @expr.init_st(@symbol_table)
    end

    def to_mips(stack_frame)
      expr.to_mips(stack_frame) + [
        "li $v0, 1",
        "or $a0, $t0, $zero",
        "syscall"
      ]
    end

    def check_types(errors)
      if expr.to_type != int_rw and expr.to_type == :not_declared
        errors << ArgumentMismatchError.new(system_out_println_rw, int_rw)
      end
      expr.check_types(errors)
    end
  end
end
