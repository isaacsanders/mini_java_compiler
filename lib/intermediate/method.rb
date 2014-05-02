require_relative "../terminals"

module Intermediate
  class Method
    include Terminals
    attr_reader :arg_list, :return_type, :return_statement,
      :id, :procedure, :symbol_table

    def initialize(id, arg_list, return_type, procedure, return_statement)
      @id = id
      @arg_list = arg_list
      @return_type = return_type
      @procedure = procedure
      @return_statement = return_statement
    end

    def init_st(parent)
      parent.add_symbol(return_type, id)
      symbol_table = SymbolTable.new(parent)
      arg_list.each do |arg|
        arg.init_st(symbol_table)
      end
      procedure.init_st(symbol_table)
    end

    def to_mips
      if main_rw == id
        procedure.to_mips
      end
    end

    def check_types(errors)
      unless arg_list.map(&:name) == arg_list.map(&:name).uniq
        arg_list.group_by(&:name).select {|id, as| as.length > 1 }.each do |(key, as)|
          errors << DuplicateArgumentError.new(id, key)
        end
      end

      if return_statement.nil?
        unless id == main_rw
          errors << TypeMismatchError.new(id, return_type, void_rw)
        end
      else
        actual_type = return_statement.to_type(procedure.symbol_table)
        unless return_type == actual_type
          errors << TypeMismatchError.new(id, return_type, actual_type)
        end
      end

      procedure.check_types(errors)
    end
  end
end
