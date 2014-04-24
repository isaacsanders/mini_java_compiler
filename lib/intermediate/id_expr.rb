require_relative 'expression'

module Intermediate
  class IDExpr < Expression
    def initialize(name)
      @name = name
    end

    def to_type(symbol_table)
      symbol_table.get_symbol(@name).type
    end

    def check_types(errors)

    end
  end
end
