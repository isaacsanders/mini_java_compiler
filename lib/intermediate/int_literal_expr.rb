require_relative "expression"
require_relative '../terminals'

module Intermediate
  class IntLiteralExpr < Expression
    include Terminals

    def initialize(value)
      @value = value
    end

    def to_type(symbol_table)
      int_rw
    end

    def check_types(errors)
    end
  end
end
