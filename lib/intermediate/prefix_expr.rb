require_relative 'expression'

module Intermediate
  class PrefixExpr < Expression
    def initialize(op, expr)
      @op, @expr = op, expr
    end

    def init_st(parent)
      super
      @expr.init_st(@symbol_table)
    end
  end
end
