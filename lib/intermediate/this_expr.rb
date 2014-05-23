require_relative "expression"
require_relative '../terminals'

module Intermediate
  class ThisExpr < Expression
    include Terminals

    attr_reader :symbol_table

    def to_type
      symbol_table.get_symbol(this_rw).type
    end

    def to_mips(stack_frame)
      [
        "or $t0, $a0, $0 # 'this' ready to be used"
      ]
    end

    def check_types(errors)
    end
  end
end
