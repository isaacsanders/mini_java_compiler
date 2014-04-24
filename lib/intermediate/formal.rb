require_relative 'errors'

module Intermediate
  class Formal
    attr_reader :name

    def initialize(type, name)
      @type, @name = type, name
    end

    def init_st(parent)
      if parent.add_symbol(@type, @name) == SymbolTable::PREEXISTS
        parent.add_error(DuplicateArgumentError.new(arg.name, arg.type))
      end
    end
  end
end
