require_relative "../stack_frame"

module Intermediate
  class Procedure
    attr_reader :statement_list

    def initialize(statement_list)
      @statement_list = statement_list
    end

    def symbol_table
      @symbol_table ||= @statement_list.last.symbol_table
    end

    def init_st(parent)
      if @statement_list.empty?
        @symbol_table = parent
      else
        @statement_list.reduce(parent) do |symbol_table, stmt|
          stmt.init_st(symbol_table)
          stmt.symbol_table
        end
      end
    end

    def to_mips(stack_frame)
      statement_list.reduce([]) do |insts, stmt|
        insts + stmt.to_mips(stack_frame)
      end
    end

    def check_types(errors)
      @statement_list.each do |stmt|
        stmt.check_types(errors)
      end
    end
  end
end
