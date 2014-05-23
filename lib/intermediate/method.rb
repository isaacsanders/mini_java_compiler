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

    def type_signature
      {
        returns: return_type,
        args: arg_list.map(&:type)
      }
    end

    def init_st(parent)
      parent.add_symbol(return_type, id)
      @symbol_table = SymbolTable.new(parent)
      arg_list.each do |formal|
        symbol_table.add_symbol(formal.type, formal.id)
      end
      procedure.init_st(symbol_table)
      if id != main_rw
        return_statement.init_st(procedure.symbol_table)
      end
    end

    def to_mips(stack_frame)
      if main_rw == id
        procedure.to_mips(stack_frame) +
          [ "jr $ra" ]
      else
        arg_list.each do |arg|
          stack_frame.add_parameter(arg.id)
        end
        [
          "#{label}:",
        ] + procedure.to_mips(stack_frame) +
        return_statement.to_mips(stack_frame) +
        [
          "or $v0, $t0, $0",
          "jr $ra # return from #{label}"
        ]
      end
    end

    def label
      "#{class_name}_#{name}"
    end

    def class_name
      class_id = symbol_table.get_symbol(this_rw).type
      klass = symbol_table.get_class(class_id).type
      while (klass.superclass.instance_variable_get(:@method_list) || []).include?(self) do
        klass = klass.superclass
      end
      klass.name
    end

    def name
      id.input_text
    end

    def check_types(errors)
      unless arg_list.map(&:name) == arg_list.map(&:name).uniq
        arg_list.group_by(&:name).select {|id, as| as.length > 1 }.each do |(key, as)|
          errors << DuplicateFormalError.new(id.input_text)
        end
      end

      if return_statement.nil?
        unless id == main_rw
          errors << MethodReturnTypeMismatchError.new(name, return_type, void_rw)
        end
      else
        actual_type = return_statement.to_type
        if return_type != actual_type and actual_type != :not_declared
          klass = symbol_table.get_class(actual_type).type
          klasses = [klass.id]
          until klass.superclass == :none
            klass = klass.superclass
            klasses << klass.id
          end

          if klasses.include? return_type || actual == null_rw
          else
            errors << MethodReturnTypeMismatchError.new(name, return_type, actual_type)
          end
        end

        if actual_type == :not_declared
          errors << NoClassError.new(return_type.input_text)
        end

        return_statement.check_types(errors)
      end

      if id == main_rw
      else
        arg_list.each do |arg|
          if [int_rw, boolean_rw].include? arg.type
          else
            symbol = symbol_table.get_class(arg.type)
            if symbol.nil?
              errors << NoClassError.new(arg.type.input_text)
            end
          end
        end
      end

      procedure.check_types(errors)
    end
  end
end
