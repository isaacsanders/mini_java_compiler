require_relative 'statement'

module Intermediate
  class BlockStatement < Statement
    attr_reader :procedure

    def initialize(procedure)
      @procedure = procedure
    end

    def init_st(parent)
      @symbol_table = SymbolTable.new(parent)
      procedure.init_st(parent)
    end

    def check_types(errors)
      procedure.check_types(errors)
    end
  end
end
