require_relative 'expression'
require_relative '../terminals'

module Intermediate
  class PrefixExpr < Expression
    extend Terminals
    include Terminals

    attr_reader :op, :expr, :symbol_table

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
      expr.init_st(symbol_table)
    end

    def to_mips(stack_frame)
      expr.to_mips(stack_frame) + operation_specific_instructions
    end

    def operation_specific_instructions
      case op
      when sub_o
        [
          "sub $t0, $0, $t0"
        ]
      when bang_o
        [
          "nor $t0, $t0, $t0",
          "lui $t1, 0x0000",
          "ori $t1, $t1, 0x0001",
          "and $t0, $t0, $t1"
        ]
      end
    end

    def check_types(errors)
      unless expr.to_type == OPERATOR_TYPES[op][:arg]
        errors << InvalidUnaryArgument.new(expr.to_type, OPERATOR_TYPES[op][:arg], OPERATOR_TYPES[op][:name])
      end
    end
  end
end
