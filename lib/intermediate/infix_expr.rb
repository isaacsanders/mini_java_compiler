require_relative 'errors'
require_relative 'expression'
require_relative '../terminals'

module Intermediate
  class InfixExpr < Expression
    extend Terminals
    include Terminals

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
      },
      eq_o => {
        name: "EQUAL",
        returns: boolean_rw
      },
      neq_o => {
        name: "NOTEQUALS",
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

    def to_mips(stack_frame)
      lhs.to_mips(stack_frame) +
        [ "addi $sp, $sp, -4",
          "sw $t0, 0($sp)" ] +
          rhs.to_mips(stack_frame) +
          [ "or $t1, $t0, $t0",
            "lw $t0, 0($sp)",
            "addi $sp, $sp, 4" ] +
            instruction_specific_mips(stack_frame)
    end

    def instruction_specific_mips(stack_frame)
      case op
      when add_o
        [
          "add $t0, $t0, $t1"
        ]
      when sub_o
        [
          "sub $t0, $t0, $t1"
        ]
      when mult_o
        [
          "mult $t0, $t1",
          "mflo $t0"
        ]
      when div_o
        [
          "div $t0, $t1",
          "mflo $t0"
        ]
      when lt_o
        [
          "slt $t0, $t0, $t1"
        ]
      when lte_o
        $branch_index += 1
        [
          "slt $t3, $t0, $t1",
          "or $t2, $0, $0",
          "bne $t0, $t1, cond#{$branch_index}",
          "addi $t2, $t2, 1",
          "cond#{$branch_index}:",
          "or $t0, $t2, $t3"
        ]
      when gt_o
        $branch_index += 1
        [
          "slt $t3, $t1, $t0",
          "or $t2, $0, $0",
          "beq $t0, $t1, cond#{$branch_index}",
          "addi $t2, $t2, 1",
          "cond#{$branch_index}:",
          "and $t0, $t2, $t3"
        ]
      when gte_o
        [
          "slt $t0, $t1, $t0"
        ]
      when and_o
        [
          "and $t0, $t0, $t1"
        ]
      when or_o
        [
          "or $t0, $t0, $t1"
        ]
      when eq_o
        $branch_index += 1
        [
          "or $t2, $0, $0",
          "beq $t0, $t1, cond#{$branch_index}",
          "addi $t2, $t2, 1",
          "cond#{$branch_index}:",
          "or $t0, $t2, $0"
        ]
      when neq_o
        $branch_index += 1
        [
          "or $t2, $0, $0",
          "bnq $t0, $t1, cond#{$branch_index}",
          "addi $t2, $t2, 1",
          "cond#{$branch_index}:",
          "or $t0, $t2, $0"
        ]
      end
    end

    def check_types(errors)
      type_signature = OPERATOR_TYPES[op]
      if [eq_o, neq_o].include? op
        if lhs.to_type == rhs.to_type
        else
          errors << InvalidRightArgument.new(rhs, lhs.to_type, type_signature[:name])
        end
      else
        if type_signature[:lhs] != lhs.to_type and lhs.to_type != :not_declared
          errors << InvalidLeftArgument.new(lhs.to_type, type_signature[:lhs], type_signature[:name])
        end
        if type_signature[:rhs] != rhs.to_type and rhs.to_type != :not_declared
          errors << InvalidRightArgument.new(rhs.to_type, type_signature[:rhs], type_signature[:name])
        end
      end
    end

    def to_type
      OPERATOR_TYPES[op][:returns]
    end
  end
end
