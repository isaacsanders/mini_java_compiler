require_relative 'statement'
require_relative '../terminals'

module Intermediate
  class IfElseStatement < Statement
    include Terminals

    attr_reader :condition_expr, :true_statement, :false_statement

    def initialize(condition_expr, true_statement, false_statement)
      @condition_expr = condition_expr # bool type
      @true_statement = true_statement
      @false_statement = false_statement
    end

    def to_mips(stack_frame)
      $branch_index += 1
      exit_label = "cond_exit#{$branch_index}"
      else_label = "cond_else#{$branch_index}"
      condition_expr.to_mips(stack_frame) +
        [ "beq $t0, $0, #{else_label}" ] +
      true_statement.to_mips(stack_frame) +
      [ "j #{exit_label}",
        "#{else_label}:" ] +
        false_statement.to_mips(stack_frame) +
        [ "#{exit_label}:",
          "sll $0, $0, 0" ]
    end

    def init_st(parent)
      super
      condition_expr.init_st(symbol_table)
      true_statement.init_st(symbol_table)
      false_statement.init_st(symbol_table)
    end

    def check_types(errors)
      condition_expr.check_types(errors)

      unless condition_expr.to_type == boolean_rw
        errors << NonbooleanIfConditionError.new(condition_expr.to_type)
      end

      true_statement.check_types(errors)
      false_statement.check_types(errors)
    end
  end
end
