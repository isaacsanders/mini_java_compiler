module Intermediate
  class Statement
    attr_reader :symbol_table
    def init_st(parent)
      @symbol_table = parent
    end
  end
end
