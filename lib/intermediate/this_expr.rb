require_relative "expression"
require_relative '../terminals'

module Intermediate
  class ThisExpr < Expression
    include Terminals

    attr_reader :symbol_table

    def to_type
      symbol_table.get_symbol(this_rw).type
    end

    def check_types(errors)
    end
  end
end
