class Program
  main_class
  class_list
end

class Class
  method_list
  field_list
  opt_extends
end

class Method
  arg_list
  return_type
  procedure
  return_statement
end

class Formal
  type
  name
end

class Procedure
  statement_list
end

class Statement
  
end

class InitStatement < Statement
  type # type type
  id
  expr # 'type' type
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
  id
  value_exp # type must match id's
end

class Expression
  
end

class InfixExpr < Expression
  expr_a
  op
  expr_b
end

class PrefixExpr < Expression
  op
  expr
end

class MethodCallExpr < Expression
  expr
  method_id # must be a member of expr's class
  arg_list # must fit in method_id's args
end

class InitExpr < Expression
  class_
end

class IDExpr < Expression
  name
end

class ThisExpr < Expression
end

class IntLiteralExpr < Expression
  value
end

class NullExpr < Expression
end
