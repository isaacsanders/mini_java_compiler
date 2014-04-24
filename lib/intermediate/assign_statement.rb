require_relative "statement"

module Intermediate
  class AssignStatement < Statement
    attr_reader :id, :value_expr
    # id
    # value_expr # type must match id's
    def initialize(id, value_expr)
      @id, @value_expr = id, value_expr
    end

    def init_st(parent)
      super
      @value_expr.init_st(@symbol_table)
    end

    def check_types(errors)
      value_expr.check_types(errors)
      expected = symbol_table.get_symbol(id)
      actual = value_expr.to_type(symbol_table)
      unless actual == expected
        errors << TypeMismatchError.new(id, expected, actual)
      end
    end
  end
end
