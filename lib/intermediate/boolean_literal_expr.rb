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

    def check_types(errors)

    end

    def to_code
      value.input_text
    end
  end
end
