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

    def name
      id.input_text
    end

    def check_types(errors)
      actual = expr.to_type

      if type != actual and actual != :not_declared
        errors << InvalidAssignmentError.new(name, actual, type)
      end

      expr.check_types(errors)
    end
  end
end
