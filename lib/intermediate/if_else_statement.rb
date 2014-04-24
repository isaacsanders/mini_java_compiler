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

    def init_st(parent)
      super
      condition_expr.init_st(symbol_table)
      true_statement.init_st(symbol_table)
      false_statement.init_st(symbol_table)
    end

    def check_types(errors)
      condition_expr.check_types(errors)

      unless condition_expr.to_type(symbol_table) == boolean_rw
        errors << UnexpectedTypeError.new(condition_expr, boolean_rw)
      end

      true_statement.check_types(errors)
      false_statement.check_types(errors)
    end
  end
end
