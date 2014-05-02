require_relative "../symbol_table"

module Intermediate
  class Program
    include Terminals
    attr_reader :symbol_table

    def initialize(main_class, class_list)
      @main_class = main_class
      @class_list = class_list
      init_st
    end

    def init_st # symbol table
      @symbol_table = SymbolTable.new(nil)
      @main_class.init_st(@symbol_table)
      @class_list.each do |klass|
        klass.init_st(@symbol_table)
      end
    end

    def to_mips
      "main:\n" +
      @main_class.method_list.detect do |method|
        method.id == main_rw
      end.to_mips + "\n" +
      "jr $ra"
    end

    def check_types
      errors = []
      @main_class.check_types(errors)
      @class_list.each_with_index do |klass, index|
        unless klass.opt_extends.nil?
          extends_index = @class_list.map(&:id).index(klass.opt_extends)
          if extends_index.nil?
            errors << UninitializedConstantError.new(klass.opt_extends)
          else
            if extends_index > index
              errors << DefineSuperclassFirstError.new(klass.id)
            end
          end
        end
        klass.check_types(errors)
      end
      errors
    end
  end
end
