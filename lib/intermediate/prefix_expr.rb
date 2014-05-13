require_relative 'expression'
require_relative '../terminals'

module Intermediate
  class PrefixExpr < Expression
    extend Terminals

    attr_reader :op

    OPERATOR_TYPES = {
      sub_o => {
        name: "NEG",
        arg: int_rw,
        returns: int_rw
      },
      bang_o => {
        name: "BANG",
        arg: boolean_rw,
        returns: boolean_rw
      }
    }

    def initialize(op, expr)
      @op, @expr = op, expr
    end

    def to_type
      OPERATOR_TYPES[op][:returns]
    end

    def init_st(parent)
      super
      @expr.init_st(@symbol_table)
    end
  end
end
