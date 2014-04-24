require_relative "statement"
require_relative "errors"
require_relative "../terminals"

module Intermediate
  class PrintlnStatement < Statement
    include Terminals

    attr_reader :expr

    def initialize(expr)
      @expr = expr # int type
    end

    def init_st(parent)
      super
      @expr.init_st(@symbol_table)
    end

    def check_types(errors)
      if expr.to_type(symbol_table) != int_rw
        errors << ArgumentMismatchError.new(system_out_println_rw, int_rw, expr.to_type(symbol_table))
      end
    end
  end
end
