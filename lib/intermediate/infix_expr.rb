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
      if op == or_o
        $branch_index += 1
        branch_label = "cond#{$branch_index}"

        lhs.to_mips(stack_frame) +
          [ "bne $t0, $0, #{branch_label}" ] +
        rhs.to_mips(stack_frame) +
        [ "#{branch_label}:",
          "sll $0, $0, 0"]
      elsif op == and_o
        $branch_index += 1
        branch_label = "cond#{$branch_index}"

        lhs.to_mips(stack_frame) +
          [ "beq $t0, $0, #{branch_label}" ] +
        rhs.to_mips(stack_frame) +
        [ "#{branch_label}:",
          "sll $0, $0, 0"]
      else
        lhs.to_mips(stack_frame) +
          [ "addi $sp, $sp, -4 # store previous $t0",
            "sw $t0, 0($sp)" ] +
            rhs.to_mips(stack_frame) +
            [ "or $t1, $t0, $t0",
              "lw $t0, 0($sp)",
              "addi $sp, $sp, 4 # restore previous $t0" ] +
              integer_operation_specific_instructions
      end
    end

    def integer_operation_specific_instructions
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
        [
          "slt $t0, $t1, $t0",
          "nor $t0, $t0, $t0",
          "lui $t1, 0x0000",
          "ori $t1, $t1, 0x0001",
          "and $t0, $t0, $t1"
        ]
      when gt_o
        [
          "slt $t0, $t1, $t0"
        ]
      when gte_o
        [
          "slt $t0, $t0, $t1",
          "nor $t0, $t0, $t0",
          "lui $t1, 0x0000",
          "ori $t1, $t1, 0x0001",
          "and $t0, $t0, $t1"
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
        [
          "slt $t2, $t0, $t1",
          "slt $t1, $t1, $t0",
          "nor $t0, $t2, $t1",
          "lui $t1, 0x0000",
          "ori $t1, $t1, 0x0001",
          "and $t0, $t0, $t1"
        ]
      when neq_o
        [
          "slt $t2, $t0, $t1",
          "slt $t1, $t1, $t0",
          "or $t0, $t2, $t1"
        ]
      end
    end

    def check_types(errors)
      type_signature = OPERATOR_TYPES[op]
      if [eq_o, neq_o].include? op
        if [null_rw, lhs.to_type].include? rhs.to_type or [null_rw, rhs.to_type].include? lhs.to_type
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
