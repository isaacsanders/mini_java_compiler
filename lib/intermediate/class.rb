require_relative '../terminals'

module Intermediate
  class Class
    include Terminals

    attr_reader :opt_extends, :id, :field_list, :symbol_table, :method_list
    attr_writer :already_exists

    def initialize(id, method_list, field_list, opt_extends)
      @id = id
      @method_list = method_list
      @field_list = field_list
      @opt_extends = opt_extends
    end

    def field_list
      if opt_extends.nil? or superclass == :class_doesnt_exist
        @field_list
      else
        @field_list + superclass.field_list
      end
    end

    def method_list
      if opt_extends.nil? or superclass == :class_doesnt_exist
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
      if opt_extends.nil?
        :none
      else
        klass = symbol_table.get_class(opt_extends)
        if klass.nil?
          :class_doesnt_exist
        else
          klass.type
        end
      end
    end

    def init_st(parent)
      @symbol_table = SymbolTable.new(parent)
      parent.add_class(self, id)
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
        data[field.to_mips_value] = offset
        offset += field.size
      end
      {
        data: {

        }
      }
    end

    def name
      id.input_text
    end

    def input_text
      id.input_text
    end

    def superclass_name
      opt_extends.input_text
    end

    def already_exists?
      @already_exists
    end

    def check_types(errors)
      if already_exists?
        errors << ClassRedeclarationError.new(name)
      else
        unless opt_extends.nil?
          if superclass == :class_doesnt_exist
            errors << NoClassError.new(superclass_name)
          else
            field_to_a = Proc.new {|f| [f.type, f.id] }
            super_field_list = superclass.field_list.map &field_to_a
            local_field_list = @field_list.map &field_to_a

            unless super_field_list == local_field_list
              local_field_list.group_by {|(t,f)| f }
              .select {|f, fs| fs.length > 1 }
              .map(&:last)
              .each do |(type, (_, fid))|
                errors << ShadowingClassVariableError.new(fid.input_text)
              end
            end

            method_to_a = Proc.new {|m| [m.id, m.type_signature] }
            super_method_list = superclass.method_list.map &method_to_a
            local_method_list = method_list.map &method_to_a

            unless Set.new(super_method_list.map(&:first)).disjoint?(Set.new(local_method_list.map(&:first)))
              super_method_list.zip(local_method_list).select do |((m1, ts1), (m2, ts2))|
                m1 == m2 && ts1 != ts2 # names are the same, but type signatures are different
              end.map {|((m, _), _)| m }.each do |method_id|
                errors << OverloadedMethodError.new(method_id.input_text)
              end
            end
          end
        end

        unless field_list.map(&:id) == field_list.map(&:id).uniq
          field_list.group_by(&:id).select {|id, fs| fs.length > 1 }.each do |(key, fs)|
            errors << ShadowingClassVariableError.new(fs.first.name)
          end
        end

        @method_list.each do |method|
          method.check_types(errors)
        end
      end
    end
  end
end
