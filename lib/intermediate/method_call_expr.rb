require_relative '../terminals'
require_relative 'expression'
require_relative 'errors'

module Intermediate
  class MethodCallExpr < Expression
    include Terminals
    attr_reader :expr, :method_id, :arg_list

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
      symbol = symbol_table.get_class(expr.to_type)
      if symbol.nil?
        :not_declared
      else
        symbol.type
      end
    end

    def to_type
      if caller_class == :not_declared
        :not_declared
      else
        caller_class.method_type(method_id)
      end
    end

    def method_name
      method_id.input_text
    end

    def method_label
      klass = caller_class
      if klass.instance_variable_get(:@method_list).map(&:id).include? method_id
      else
        while (klass.superclass.instance_variable_get(:@method_list) || []).map(&:id).include? method_id
          klass = klass.superclass
        end
      end
      "#{klass.name}_#{method_name}"
    end

    def to_mips(stack_frame)
      [
        "addi $sp, $sp, -4 # #{method_name}: push 'this'",
        "sw $a0, 0($sp)",
        "addi $sp, $sp, -4 # #{method_name}: push $fp",
        "sw $fp, 0($sp)",
        "addi $sp, $sp, #{-4 * (arg_list.length + 1)} # #{method_name}: push args (in reverse) and $ra",
      ] + arg_list.each_with_index.reduce([]) do |acc, (arg, i)|
        arg.to_mips(stack_frame) +
        [ "sw $t0, #{4 * (i + 1)}($sp) # #{method_name}: push arg#{i + 1}" ] +
        acc
      end + expr.to_mips(stack_frame) + [
        "or $a0, $t0, $0",
        "sw $ra, 0($sp)",
        "or $fp, $sp, $0", # establish frame pointer
        "jal #{method_label}",
        "or $t0, $v0, $0",
        "lw $ra, 0($sp)",
        "addi $sp, $sp, #{4 * (arg_list.length + 1)} # #{method_name}: pop args and $ra",
        "lw $fp, 0($sp)",
        "addi $sp, $sp, 4 # #{method_name}: pop $fp",
        "lw $a0, 0($sp)",
        "addi $sp, $sp, 4 # #{method_name}: pop 'this'"
      ]
    end

    def check_types(errors)
      if caller_class != :not_declared
        method = caller_class.method_list.detect {|m| m.id == method_id }
        if method.nil?
          errors << Intermediate::NoMethodError.new(method_name, expr.to_type)
        else
          arg_list.map(&:to_type).zip(method.arg_list.map(&:type)).reject do |(actual, declared)|
            if [int_rw, boolean_rw].include? declared
              actual == declared
            else
              klass = symbol_table.get_class(actual).type
              klasses = [klass.id]
              while klass.superclass != :none
                klass = klass.superclass
                klasses << klass.id
              end

              klasses.include? declared
            end
          end.each do |(actual, declared)|
            errors << ArgumentMismatchError.new(actual, declared)
          end
        end
      end
      expr.check_types(errors)
      arg_list.each do |arg|
        arg.check_types(errors)
      end
    end
  end
end
