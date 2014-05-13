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
  end
end
