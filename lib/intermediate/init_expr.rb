require_relative "expression"

module Intermediate
  class InitExpr < Expression
    attr_reader :klass

    def initialize(klass)
      @klass = klass
    end

    def init_st(parent)
      super
      # todo?
    end

    def to_type
      klass
    end

    def check_types(errors)
    end

    def to_code
      "new #{klass.input_text}()"
    end
  end
end
