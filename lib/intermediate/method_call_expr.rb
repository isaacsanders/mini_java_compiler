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
      @caller_class ||= symbol_table.get_symbol(expr.to_type).type
    end

    def to_type
      caller_class.method_type(method_id)
    end

    def to_code
      args = arg_list.map(&:to_code).join(", ")
      "#{expr.to_code}.#{method_id.input_text}(#{args})"
    end

    def check_types(errors)
      method = caller_class.method_list.detect {|m| m.id == method_id }
      if method.nil?
        errors << Intermediate::NoMethodError.new(method_id, expr)
      else
        arg_list.map(&:to_type).zip(method.arg_list.map(&:type)).select do |(actual, expected)|
          actual == expected
        end.each do |(actual, expected)|
          errors << UnexpectedTypeError.new(actual, expected.type)
        end
      end
    end
  end
end
