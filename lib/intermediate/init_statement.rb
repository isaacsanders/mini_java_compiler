require_relative '../symbol_table'
require_relative '../terminals'
require_relative 'statement'
require_relative 'errors'

module Intermediate
  class InitStatement < Statement
    include Terminals
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

    def to_mips(stack_frame)
      mips_evaluate(stack_frame) + mips_assign(stack_frame)
    end

    def mips_evaluate(stack_frame)
      expr.to_mips(stack_frame)
    end

    def mips_assign(stack_frame)
      [
        "or #{stack_frame.set_next_register(id)}, $t0, $0"
      ]
    end

    def to_type
      if [int_rw, boolean_rw].include? type
        type
      else
        symbol = symbol_table.get_class(type)
        if symbol.nil?
          :not_declared
        else
          symbol.id.last
        end
      end
    end

    def check_types(errors)
      actual = expr.to_type

      if type != actual and actual != :not_declared
        errors << InvalidAssignmentError.new(name, actual, type)
      end


      if to_type == :not_declared
        errors << NoClassError.new(type.input_text)
      end

      expr.check_types(errors)
    end
  end
end
