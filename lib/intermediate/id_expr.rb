require_relative 'expression'
require_relative '../terminals'

module Intermediate
  class IDExpr < Expression
    include Terminals
    attr_reader :id, :symbol_table

    def initialize(id)
      @id = id
    end

    def to_type
      symbol = symbol_table.get_symbol(id)
      if symbol.nil?
        klass_name = symbol_table.get_symbol(this_rw).type
        klass = symbol_table.get_class(klass_name).type
        symbol = klass.field_list.detect {|f| f.id == id }
        if symbol.nil?
          :not_declared
        else
          symbol.type
        end
      else
        symbol.type
      end
    end

    def check_types(errors)
      errors
    end

    def input_text
      name
    end

    def name
      id.input_text
    end
  end
end
