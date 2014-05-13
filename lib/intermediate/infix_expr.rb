require_relative 'errors'
require_relative 'expression'
require_relative '../terminals'

module Intermediate
  class InfixExpr < Expression
    extend Terminals

    OPERATOR_TYPES = {
      add_o => {
        name: "PLUS",
        lhs: int_rw,
        rhs: int_rw,
        returns: int_rw
      },
      sub_o => {
        name: "MINUS",
        lhs: int_rw,
        rhs: int_rw,
        returns: int_rw
      },
      mult_o => {
        name: "TIMES",
        lhs: int_rw,
        rhs: int_rw,
        returns: int_rw
      },
      div_o => {
        name: "DIVIDE",
        lhs: int_rw,
        rhs: int_rw,
        returns: int_rw
      },
      lt_o => {
        name: "LT",
        lhs: int_rw,
        rhs: int_rw,
        returns: boolean_rw
      },
      lte_o => {
        name: "LTE",
        lhs: int_rw,
        rhs: int_rw,
        returns: boolean_rw
      },
      gt_o => {
        name: "GT",
        lhs: int_rw,
        rhs: int_rw,
        returns: boolean_rw
      },
      gte_o => {
        name: "GTE",
        lhs: int_rw,
        rhs: int_rw,
        returns: boolean_rw
      },
      and_o => {
        name: "AND",
        lhs: boolean_rw,
        rhs: boolean_rw,
        returns: boolean_rw
      },
      or_o => {
        name: "OR",
        lhs: boolean_rw,
        rhs: boolean_rw,
        returns: boolean_rw
      }
    }

    attr_reader :lhs, :op, :rhs, :symbol_table

    def initialize(lhs, op, rhs)
      @lhs, @op, @rhs = lhs, op, rhs
    end

    def init_st(parent)
      super
      lhs.init_st(symbol_table)
      rhs.init_st(symbol_table)
    end

    def check_types(errors)
      type_signature = OPERATOR_TYPES[op]
      unless type_signature[:lhs] == lhs.to_type(symbol_table)
        errors << InvalidLeftArgument.new(lhs, type_signature[:lhs], type_signature[:name])
      end
      unless type_signature[:rhs] == rhs.to_type(symbol_table)
        errors << InvalidRightArgument.new(rhs, type_signature[:rhs], type_signature[:name])
      end
    end

    def to_type(symbol_table)
      OPERATOR_TYPES[op][:returns]
    end
  end
end
