require_relative 'expression'
require_relative 'errors'

module Intermediate
  class MethodCallExpr < Expression
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

    def check_types(errors)
      if caller_class != :not_declared
        method = caller_class.method_list.detect {|m| m.id == method_id }
        if method.nil?
          errors << Intermediate::NoMethodError.new(method_name, expr.to_type)
        else
          arg_list.map(&:to_type).zip(method.arg_list.map(&:type)).select do |(actual, declared)|
            actual == declared
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
