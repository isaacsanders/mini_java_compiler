require_relative 'expression'

module Intermediate
  class MethodCallExpr < Expression
    attr_reader :expr, :method_id

    def initialize(expr, method_id, arg_list)
      @expr, @method_id, @arg_list = expr, method_id, arg_list
    end
    # expr
    # method_id - must be a member of expr's class
    # arg_list - must fit in method_id's args

    def init_st(parent)
      super
      @expr.init_st(symbol_table)
      @arg_list.each do |arg|
        arg.init_st(symbol_table)
      end
    end

    def caller_class
      symbol_table.get_symbol(expr.to_type(symbol_table)).type
    end

    def to_type(symbol_table)
      caller_class.symbol_table.get_symbol(method_id).type
    end

    def check_types(errors)
      method = caller_class.method_list.detect {|m| m.id == method_id }
      unless arg_list.zip(method.arg_list).all? do |(actual, expected)|
        actual.to_type == expected.type
      end
        errors << ImproperArgumentError.new
      end
      raise "hell"
    end
  end
end
