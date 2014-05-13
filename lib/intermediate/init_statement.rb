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
      super
      expr.init_st(symbol_table)
      symbol_table.add_symbol(type, id)
    end

    def check_types(errors)
      actual = expr.to_type

      if actual.is_a? Lexer::ID
        current = symbol_table.get_symbol(actual).type
        ancestors = []
        until current == :none
          ancestors << current
          current = current.superclass
        end
      else
        unless type == actual
          errors << InvalidAssignmentError.new(id, actual, type)
        end
      end

      expr.check_types(errors)
    end
  end
end
