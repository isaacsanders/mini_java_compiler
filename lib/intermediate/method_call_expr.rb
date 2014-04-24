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
      @expr.init_st(@symbol_table)
      @arg_list.each do |arg|
        arg.init_st(@symbol_table)
      end
    end

    def to_type(symbol_table)
      klass = symbol_table.get_symbol(expr.to_type(symbol_table)).type
      klass.symbol_table.get_symbol(method_id).type
    end
  end
end
