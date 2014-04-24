require_relative "expression"
require_relative "../terminals"

module Intermediate
  class BooleanLiteralExpr < Expression
    include Terminals

    def initialize(value)
      @value = value
    end

    def to_type(symbol_table)
      boolean_rw
    end
  end
end
