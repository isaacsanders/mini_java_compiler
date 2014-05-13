require_relative "expression"
require_relative '../terminals'

module Intermediate
  class IntLiteralExpr < Expression
    include Terminals

    attr_reader :value

    def initialize(value)
      @value = value
    end

    def to_type
      int_rw
    end

    def to_mips_value
      value.input_text.to_i
    end

    def check_types(errors)
    end
  end
end
