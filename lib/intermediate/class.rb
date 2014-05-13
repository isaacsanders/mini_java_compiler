require_relative '../terminals'

module Intermediate
  class Class
    include Terminals

    attr_reader :opt_extends, :id, :field_list, :symbol_table, :method_list

    def initialize(id, method_list, field_list, opt_extends)
      @id = id
      @method_list = method_list
      @field_list = field_list
      @opt_extends = opt_extends
    end

    def method_list
      if opt_extends.nil?
        @method_list
      else
        @method_list + superclass.method_list
      end
    end

    def method_type(method_id)
      symbol = symbol_table.get_symbol(method_id)
      if symbol.nil?
        if opt_extends.nil?
          null_rw
        else
          superclass.method_type(method_id)
        end
      else
        symbol.type
      end
    end

    def superclass
      symbol_table.get_symbol(opt_extends).type
    end

    def init_st(parent)
      @symbol_table = SymbolTable.new(parent)
      parent.add_symbol(self, id)
      symbol_table.add_symbol(id, this_rw)
      field_list.each do |f|
        f.init_st(symbol_table)
      end
      method_list.each do |m|
        m.init_st(symbol_table)
      end
    end

    def to_mips
      data = Hash.new
      offset = 0
      field_list.each do |field|
        data["#{id.to_code}_#{field.to_code}".to_sym] = offset
        offset += field.size
      end
      {
        data: {

        }
      }
    end

    def check_types(errors)
      if opt_extends
        superclass = symbol_table.get_symbol(opt_extends)
        unless superclass.nil?
          superclass = symbol_table.get_symbol(opt_extends).type
          field_to_a = Proc.new {|f| [f.type, f.id] }
          super_field_set = Set.new(superclass.field_list.map &field_to_a )
          field_set = Set.new(field_list.map &field_to_a )

          unless super_field_set.disjoint?(field_set)
            super_field_set.intersection(field_set).each do |(type, fid)|
              errors << ShadowingClassVariableError.new(id, fid)
            end
          end

          super_method_list = Set.new(superclass.method_list.map(&:id))
          local_method_list = Set.new(method_list.map(&:id))

          unless super_method_list.disjoint?(local_method_list)
            super_method_list.intersection(local_method_list).each do |method_id|
              errors << OverloadedMethodError.new(method_id)
            end
          end
        end
      end

      unless field_list.map(&:id) == field_list.map(&:id).uniq
        field_list.group_by(&:id).select {|id, fs| fs.length > 1 }.each do |(key, fs)|
          errors << DuplicateFieldError.new(id, key)
        end
      end

      @method_list.each do |method|
        method.check_types(errors)
      end
    end
  end
end
