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

    def check_types(errors)
      unless condition_expr.to_type(symbol_table) == boolean_rw
        errors << UnexpectedTypeError.new(condition_expr, boolean_rw)
      end

      statement.check_types(errors)
    end
  end
end
