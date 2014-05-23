require_relative "expression"
require_relative "../terminals"

module Intermediate
  class NullExpr < Expression
    include Terminals

    def to_type
      null_rw
    end

    def check_types(errors)

    end

    def to_mips(stack_frame)
      [
        "or $t0, $0, $0"
      ]
    end

    def input_text
      null_rw.input_text
    end
  end
end
