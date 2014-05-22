require_relative "statement"
require_relative "errors"

module Intermediate
  class WhileStatement < Statement
    include Terminals

    attr_reader :condition_expr, :statement

    def initialize(condition_expr, statement, for_mode=false)
      @condition_expr = condition_expr # bool type
      @statement = statement
      @for_mode = for_mode
    end

    def init_st(parent)
      super
      condition_expr.init_st(symbol_table)
      statement.init_st(symbol_table)
    end

    def to_mips(stack_frame)
      $loop_stack.push $loop_counter
      $loop_counter += 1
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
      unless for_mode
        intrs = ["#{loop_continue}:"] + intrs
      end
      $loop_stack.pop
      intrs
    end

    def loop_start
      "loop#{$loop_stack.last}"
    end

    def loop_end
      "exit#{$loop_stack.last}"
    end

    def loop_continue
      "continue#{$loop_stack.last}"
    end

    def check_types(errors)
      unless condition_expr.to_type == boolean_rw
        errors << NonbooleanWhileConditionError.new(condition_expr.to_type)
      end

      statement.check_types(errors)
    end
  end
end
