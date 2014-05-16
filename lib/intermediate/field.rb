module Intermediate
  class Field
    attr_reader :id, :type, :symbol_table

    def initialize(type, id)
      @type, @id = type, id
    end

    def to_mips_value
      "#{enclosing_class.name}_#{name}".to_sym
    end

    def enclosing_class
      class_name = symbol_table.get_symbol(this_rw).type
      @enclosing_class ||= symbol_table.get_class(class_name).type
    end

    def name
      id.input_text
    end

    def init_st(parent)
      parent.add_field(@type, @id)
      @symbol_table = parent
    end
  end
end
