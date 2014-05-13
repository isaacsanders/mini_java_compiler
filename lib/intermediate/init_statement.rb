require_relative '../symbol_table'
require_relative 'statement'
require_relative 'errors'

module Intermediate
  class InitStatement < Statement
    attr_reader :type, :expr, :id, :symbol_table

    def initialize(type, id, expr)
      @type, @id, @expr = type, id, expr
    end

    def init_st(parent)
      @symbol_table = SymbolTable.new(parent)
      expr.init_st(@symbol_table.dup)
      @symbol_table.add_symbol(type, id)
    end

    def check_types(errors)
      actual = expr.to_type(symbol_table)
      unless type == actual
        errors << InvalidAssignmentError.new(id, actual, type)
      end

      expr.check_types(errors)
    end
  end
end
