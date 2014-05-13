require 'objspace'
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
      p method_id
      @caller_class ||= symbol_table.get_symbol(expr.to_type(symbol_table)).type
    end

    def to_type(symbol_table)
      caller_class.method_type(method_id)
    end

    def to_code
      args = arg_list.map(&:to_code).join(", ")
      "#{expr.to_code}.#{method_id.input_text}(#{args})"
    end

    def check_types(errors)
      method = caller_class.method_list.detect {|m| m.id == method_id }
      if method.nil?
        errors << Intermediate::NoMethodError.new(expr, method_id)
      else
        arg_list.zip(method.arg_list).select do |(actual, expected)|
          actual.to_type(symbol_table) == expected.type
        end.each do |(actual, expected)|
          errors << UnexpectedTypeError.new(actual, expected.type)
        end
      end
    end
  end
end
