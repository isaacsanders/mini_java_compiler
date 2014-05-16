require_relative "statement"

module Intermediate
  class AssignStatement < Statement
    include Terminals

    attr_reader :id, :value_expr, :symbol_table
    # id
    # value_expr # type must match id's
    def initialize(id, value_expr)
      @id, @value_expr = id, value_expr
    end

    def init_st(parent)
      super
      value_expr.init_st(symbol_table)
    end

    def enclosing_class
      name = symbol_table.get_symbol(this_rw).type
      symbol_table.get_class(name).type
    end

    def to_type
      symbol = symbol_table.get_symbol(id)
      if symbol.nil?
        symbol = enclosing_class.field_list.detect do |field|
          field.id == id
        end
      end
      symbol.type
    end

    def name
      id.input_text
    end

    def check_types(errors)
      symbol = symbol_table.get_symbol(id)
      if symbol.nil?
        errors << UndeclaredVariableError.new(name)
      else
        declared = to_type
        actual = value_expr.to_type
        if actual != declared and actual != :not_declared
          errors << InvalidAssignmentError.new(name, actual, declared)
        end
        value_expr.check_types(errors)
      end
    end
  end
end
