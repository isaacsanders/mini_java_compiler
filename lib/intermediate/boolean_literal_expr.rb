require_relative "expression"
require_relative "../terminals"

module Intermediate
  class BooleanLiteralExpr < Expression
    include Terminals

    attr_reader :value

    def initialize(value)
      @value = value
    end

    def to_type
      boolean_rw
    end

    def mips_value
      if value == true_rw
        1
      else
        0
      end
    end

    def to_mips(stack_frame)
      [
        "li $t0, #{mips_value}"
      ]
    end

    def check_types(errors)

    end
  end
end
