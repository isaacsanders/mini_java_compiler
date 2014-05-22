require_relative "statement"
require_relative "errors"

module Intermediate
  class WhileStatement < Statement
    include Terminals

    attr_reader :condition_expr, :statement

    def initialize(condition_expr, statement)
      @condition_expr = condition_expr # bool type
      @statement = statement
    end

    def init_st(parent)
      super
      condition_expr.init_st(symbol_table)
      statement.init_st(symbol_table)
    end

    def to_mips(stack_frame)
      intrs = [
        "#{loop_start}:"
      ] +
      condition_expr.to_mips(stack_frame) + [
        "beq $0, $t0, #{loop_end}"
      ] +
      statement.to_mips(stack_frame) + [
        "j #{loop_start}",
        "#{loop_end}:",
        "sll $0, $0, 0"
      ]
      $loop_counter += 1
      intrs
    end

    def loop_start
      "loop#{$loop_counter}"
    end

    def loop_end
      "exit#{$loop_counter}"
    end

    def check_types(errors)
      unless condition_expr.to_type == boolean_rw
        errors << NonbooleanWhileConditionError.new(condition_expr.to_type)
      end

      statement.check_types(errors)
    end
  end
end
