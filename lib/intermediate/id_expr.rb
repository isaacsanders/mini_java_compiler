require_relative 'expression'
require_relative '../terminals'

module Intermediate
  class IDExpr < Expression
    include Terminals
    attr_reader :name, :symbol_table

    def initialize(name)
      @name = name
    end

    def to_type
      symbol = symbol_table.get_symbol(name)
      if symbol.nil?
        klass_name = symbol_table.get_symbol(this_rw).type
        klass = symbol_table.get_symbol(klass_name).type
        symbol = klass.symbol_table.get_symbol(name)
      end
      symbol.type
    end

    def check_types(errors)
      errors
    end

    def to_code
      to_type.to_code
    end
  end
end
