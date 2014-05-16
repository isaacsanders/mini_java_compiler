require_relative "expression"

module Intermediate
  class InitExpr < Expression
    attr_reader :klass

    def initialize(klass)
      @klass = klass
    end

    def to_type
      klass
    end

    def check_types(errors)
    end
  end
end
