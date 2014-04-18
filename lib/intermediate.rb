require_relative "symbol_table"

module Intermediate
  class DefineSuperclassFirstError
    def initialize(klass_id)
      @klass_id = klass_id
    end
  end

  class DuplicateFieldError
    def initialize(klass_id, id)
      @klass_id, @id = klass_id, id
    end
  end

  class ShadowingClassVariableError
    def initialize(klass_id, id)
      @klass_id, @id = klass_id, id
    end
  end

  class Program
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

    def check_types
      errors = []
      @main_class.check_types(errors)
      @class_list.each_with_index do |klass, index|
        unless klass.opt_extends.nil?
          if @class_list.map(&:id).index(klass.opt_extends) > index
            errors << DefineSuperclassFirstError.new(klass.id)
          end
        end
        klass.check_types(errors)
      end
      errors
    end
  end

  class Class
    attr_reader :opt_extends, :id, :field_list, :symbol_table

    def initialize(id, method_list, field_list, opt_extends)
      @id, @method_list, @field_list, @opt_extends = id, method_list, field_list, opt_extends
    end

    def init_st(parent)
      @symbol_table = SymbolTable.new(parent)
      parent.add_symbol(self, @id)
      @field_list.each do |f|
        f.init_st(@symbol_table)
      end
      @method_list.each do |m|
        m.init_st(@symbol_table)
      end
    end

    def check_types(errors)
      if opt_extends
        superclass = symbol_table.get_symbol(opt_extends).type

        unless field_list.map(&:id) == field_list.map(&:id).uniq
          field_list.group_by(&:id).select {|id, fs| fs.length > 1 }.each do |(key, fs)|
            errors << DuplicateFieldError.new(id, key)
          end
        end

        p super_field_set = Set.new(superclass.field_list.map {|f| [f.type, f.id] })
        p field_set = Set.new(field_list.map {|f| [f.type, f.id] })

        unless super_field_set.disjoint?(field_set)
          super_field_set.intersection(field_set).each do |(type, fid)|
            errors << ShadowingClassVariableError.new(id, fid)
          end
        end
      end
    end
  end

  class Field
    attr_reader :id, :type

    def initialize(type, id)
      @type, @id = type, id
    end

    def init_st(parent)
      parent.add_symbol(@type, @id)
    end
  end

  class Method
    def initialize(id, arg_list, return_type, procedure, return_statement)
      @id,
      @arg_list,
      @return_type,
      @procedure,
      @return_statement = id, arg_list, return_type, procedure, return_statement
    end

    def init_st(parent)
      parent.add_symbol(@return_type, @id)
      @symbol_table = SymbolTable.new(parent)
      @arg_list.each do |arg|
        arg.init_st(@symbol_table)
      end
    end
  end

  class Formal
    def initialize(type, name)
      @type, @name = type, name
    end

    def init_st(parent)
      if parent.add_symbol(@type, @name) == :preexists
        parent.add_error(DuplicateArgumentError.new(arg.name, arg.type))
      end
    end
  end

  class Procedure
    def initialize(statement_list)
      @statement_list = statement_list
    end

    def init_st(parent)
      @statement_list.reduce(parent) do |symbol_table, stmt|
        stmt.init_st(symbol_table)
        stmt.symbol_table
      end
    end
  end

  class Statement
    attr_reader :symbol_table
    def init_st(parent)
      @symbol_table = parent
    end
  end

  class InitStatement < Statement
    def initialize(type, id, expr)
      @type, @id, @expr = type, id, expr
    end
    # type # type type
    # id
    # expr # 'type' type

    def init_st(parent)
      @symbol_table = SymbolTable.new(parent)
      @symbol_table.add_symbol(@type, @id)
    end
  end

  class BlockStatement < Statement
    def initialize(procedure)
      @procedure = procedure
    end

    def init_st(parent)
      @symbol_table = SymbolTable.new(parent)
      procedure.init_st(parent)
    end
  end

  class IfElseStatement < Statement
    def initialize(condition_expr, true_statement, false_statement)
      @condition_expr = condition_expr # bool type
      @true_statement = true_statement
      @false_statement = false_statement
    end

    def init_st(parent)
      super
      @condition_expr.init_st(@symbol_table)
      @true_statement.init_st(@symbol_table)
      @false_statement.init_st(@symbol_table)
    end
  end

  class WhileStatement < Statement
    def initialize(condition_expr, statement)
      @condition_expr = condition_expr # bool type
      @statement = statement
    end

    def init_st(parent)
      super
      @condition_expr.init_st(@symbol_table)
      @statement.init_st(@symbol_table)
    end
  end

  class PrintlnStatement < Statement
    def initialize(expr)
      @expr = expr # int type
    end

    def init_st(parent)
      super
      @expr.init_st(@symbol_table)
    end
  end

  class AssignStatement < Statement
    # id
    # value_expr # type must match id's
    def initialize(id, value_expr)
      @id, @value_expr = id, value_expr
    end

    def init_st(parent)
      super
      @value_expr.init_st(@symbol_table)
    end
  end

  class Expression
    def init_st(parent)
      @symbol_table = parent
    end
  end

  class InfixExpr < Expression
    def initialize(lhs, op, rhs)
      @lhs, @op, @rhs = lhs, op, rhs
    end

    def init_st(parent)
      super
      @lhs.init_st(@symbol_table)
      @rhs.init_st(@symbol_table)
    end
  end

  class PrefixExpr < Expression
    def initialize(op, expr)
      @op, @expr = op, expr
    end

    def init_st(parent)
      super
      @expr.init_st(@symbol_table)
    end
  end

  class MethodCallExpr < Expression
    def initialize(expr, method_id, arg_list)
      @expr, @method_id, @arg_list = expr, method_id, arg_list
    end
    # expr
    # method_id - must be a member of expr's class
    # arg_list - must fit in method_id's args

    def init_st(parent)
      super
      @expr.init_st(@symbol_table)
      @arg_list.each do |arg|
        arg.init_st(@symbol_table)
      end
    end
  end

  class InitExpr < Expression
    def initialize(klass)
      @klass = klass
    end

    def init_st(parent)
      super
      # todo?
    end
  end

  class IDExpr < Expression
    def initialize(name)
      @name = name
    end
  end

  class ThisExpr < Expression
  end

  class IntLiteralExpr < Expression
    def initialize(value)
      @value = value
    end
  end

  class NullExpr < Expression
  end

  class BooleanLiteral < Expression
    def initialize(value)
      @value = value
    end
  end
end
