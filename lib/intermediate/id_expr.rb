require_relative 'expression'
require_relative '../terminals'

module Intermediate
  class IDExpr < Expression
    include Terminals
    attr_reader :id, :symbol_table

    def initialize(id)
      @id = id
    end

    def to_type
      symbol = symbol_table.get_symbol(id)
      if symbol.nil?
        klass_name = symbol_table.get_symbol(this_rw).type
        klass = symbol_table.get_class(klass_name).type
        symbol = klass.field_list.detect {|f| f.id == id }
        if symbol.nil?
          :not_declared
        else
          symbol.type
        end
      else
        symbol.type
      end
    end

    def to_mips(stack_frame)
      if stack_frame.has_register_for?(id)
        saved_register = stack_frame.get_register(id)
        [
          "or $t0, #{saved_register}, $zero"
        ]
      else
        if stack_frame.has_frame_offset_for?(id)
          frame_offset = stack_frame.frame_offset(id)
          [
            "lw $t0, #{frame_offset}($fp)"
          ]
        else
          if stack_frame.has_field_offset_for?(id)
            field_offset = stack_frame.field_offset(id)
            [
              "lw $t0, #{field_offset}($a0)"
            ]
          else
            raise "Massive Problem"
          end
        end
      end
    end

    def check_types(errors)
      errors
    end

    def input_text
      name
    end

    def name
      id.input_text
    end
  end
end
