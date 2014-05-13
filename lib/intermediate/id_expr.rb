require_relative 'expression'

module Intermediate
  class IDExpr < Expression
    attr_reader :name, :symbol_table

    def initialize(name)
      @name = name
    end

    def to_type(symbol_table)
      symbol_table.get_symbol(name).type
    end

    def check_types(errors)

    end

    def to_code
      to_type(symbol_table).to_code
    end
  end
end
