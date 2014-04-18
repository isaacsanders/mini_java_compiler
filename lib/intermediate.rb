module Intermediate
  class Program
    def initialize(main_class, class_list)
      @main_class = main_class
      @class_list = class_list
    end

    def init_st # symbol table
      @symbol_table = SymbolTable.new(nil)
      @main_class.init_st(@symbol_table)
      @class_list.init_st(@symbol_table)
    end
  end

  class Class
    def initialize(id, method_list, field_list, opt_extends)
      @id, @method_list, @field_list, @opt_extends = id, method_list, field_list, opt_extends
    end
  end

  class Field
    def initialize(type, id)
      @type, @id = type, id
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
  end

  class Formal
    def initialize(type, name)
      @type, @name = type, name
    end
  end

  class Procedure
    def initialize(statement_list)
      @statement_list = statement_list
    end
  end

  class Statement

  end

  class InitStatement < Statement
    def initialize(type, id, expr)
      @type, @id, @expr = type, id, expr
    end
    # type # type type
    # id
    # expr # 'type' type
  end

  class BlockStatement < Statement
    procedure
  end

  class IfElseStatement < Statement
    condition_expr # bool type
    true_statement
    false_statement
  end

  class WhileStatement < Statement
    condition_expr # bool type
    statement
  end

  class PrintlnStatement < Statement
    expr # int type
  end

  class AssignStatement < Statement
    # id
    # value_exp # type must match id's
    def initialize(id, value_exp)
      @id, @value_exp = id, value_exp
    end
  end

  class Expression

  end

  class InfixExpr < Expression
    def initialize(lhs, op, rhs)
      @lhs, @op, @rhs = lhs, op, rhs
    end
  end

  class PrefixExpr < Expression
    def initialize(op, expr)
      @op, @expr = op, expr
    end
  end

  class MethodCallExpr < Expression
    def initialize(expr, method_id, arg_list)
      @expr, @method_id, @arg_list = expr, method_id, arg_list
    end
    # expr
    # method_id - must be a member of expr's class
    # arg_list - must fit in method_id's args
  end

  class InitExpr < Expression
    def initialize(klass)
      @klass = klass
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
