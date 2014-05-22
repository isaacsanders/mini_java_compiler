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
      classes.group_by(&:id).select {|id, cls| cls.length > 1 }.each do |(id, cls)|
        cl = cls.first
        cl.already_exists = true
      end
      @main_class.init_st(@symbol_table)
      @class_list.each do |klass|
        klass.init_st(@symbol_table)
      end
    end

    def classes
      [@main_class] + @class_list
    end

    def to_mips
      $loop_counter = 0
      $loop_stack = Array.new
      @class_list.map(&:to_mips).join("\n") +
        @main_class.method_list.map {|m| m.to_mips(StackFrame.new) }.join("\n")
    end

    def check_types
      errors = []
      @main_class.check_types(errors)
      @class_list.each_with_index do |klass, index|
        unless klass.opt_extends.nil?
          extends_index = @class_list.map(&:id).index(klass.opt_extends)
          if extends_index.nil? || extends_index > index
            errors << NoClassError.new(klass.superclass_name)
          end
        end
        klass.check_types(errors)
      end
      errors
    end
  end
end
