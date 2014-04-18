# -*- coding: utf-8 -*-
require_relative 'terminals'
require_relative 'intermediate'

class Nonterminal
  include Terminals

  def epsilon?
    not @epsilon.nil?
  end
end

class Program < Nonterminal
  def fill_slots(table_entry)
    @main_class_decl, @class_decl_list = table_entry
  end

  def to_ir
    main_class_ir = @main_class_decl.to_ir
    other_classes_ir = @class_decl_list.to_ir
    return Intermediate::Program.new(main_class_ir, other_classes_ir)
  end
end

class MainClassDecl < Nonterminal
  def fill_slots(table_entry)
    _, @id, _, _, _, _, _, _, _, _, _, @arg_id, _, _, @stmt_list, _, _ = table_entry
  end

  def to_ir
    field_list = []
    method_list = [Intermediate::Method.new(main_rw, [Intermediate::Formal.new('String[]', @arg_id)], 'void', @stmt_list.to_ir, nil)]
    opt_extends = nil
    Intermediate::Class.new(@id, method_list, field_list, opt_extends)
  end
end

class ClassDeclList < Nonterminal
  def fill_slots(table_entry)
    if table_entry.length == 1
      @epsilon = table_entry.first
    else
      @class_decl, @class_decl_list = table_entry
    end
  end

  def to_ir
    return [] if self.epsilon?
    [@class_decl.to_ir] + @class_decl_list.to_ir
  end
end

class ClassDecl < Nonterminal
  def fill_slots(table_entry)
    _, @id, @class_decl_prime = table_entry
  end

  def to_ir
    @class_decl_prime.to_ir(@id)
  end
end

class ClassDeclPrime < Nonterminal
  def fill_slots(table_entry)
    if table_entry.length == 4
      _, @class_var_decl_list, @method_decl_list, _ = table_entry
    else
      _, @extends_id, _, @class_var_decl_list, @method_decl_list, _ = table_entry
    end
  end

  def to_ir(id)
    field_list = @class_var_decl_list.to_ir
    method_list = @method_decl_list.to_ir
    opt_extends = @extends_id
    Intermediate::Class.new(id, method_list, field_list, opt_extends)
  end
end

class ClassVarDeclList < Nonterminal
  def fill_slots(table_entry)
    if table_entry.length == 1
      @epsilon = table_entry.first
    else
      @class_var_decl, @class_var_decl_list = table_entry
    end
  end

  def to_ir
    return [] if self.epsilon?
    [@class_var_decl.to_ir] + @class_var_decl_list.to_ir
  end
end

class ClassVarDecl < Nonterminal
  def fill_slots(table_entry)
    @type, @id, _ = table_entry
  end

  def to_ir
    Intermediate::Field.new(@type.to_ir, @id)
  end
end

class MethodDeclList < Nonterminal
  def fill_slots(table_entry)
    if table_entry.length == 1
      @epsilon = table_entry.first
    else
      @method_decl, @method_decl_list = table_entry
    end
  end

  def to_ir
    return [] if self.epsilon?
    [@method_decl.to_ir] + @method_decl_list.to_ir
  end
end

class MethodDecl < Nonterminal
  def fill_slots(table_entry)
    _, @type, @id, _, @formal_list, _, _, @stmt_list, _, @expr, _, _ = table_entry
  end

  def to_ir
    formals = @formal_list.to_ir
    stmts = @stmt_list.to_ir
    return_type = @type.to_ir
    return_expr = @expr.to_ir
    Intermediate::Method.new(@id, formals, return_type, stmts, return_expr)
  end
end

class FormalList < Nonterminal
  def fill_slots(table_entry)
    if table_entry.length == 1
      @epsilon = table_entry.first
    else
      @formal, @formal_list_prime = table_entry
    end
  end

  def to_ir
    return [] if self.epsilon?
    [@formal.to_ir] + @formal_list_prime.to_ir
  end
end

class FormalListPrime < Nonterminal
  def fill_slots(table_entry)
    if table_entry.length == 1
      @epsilon = table_entry.first
    else
      _, @formal, @formal_list_prime = table_entry
    end
  end

  def to_ir
    return [] if self.epsilon?
    [@formal.to_ir] + @formal_list_prime.to_ir
  end
end

class Formal < Nonterminal
  def fill_slots(table_entry)
    @type, @id = table_entry
  end

  def to_ir
    Intermediate::Formal.new(@type.to_ir, @id)
  end
end

class Type < Nonterminal
  def fill_slots(table_entry)
    @type = table_entry.first
  end

  def to_ir
    case @type
    when TypeNotID
      @type.type
    when Lexer::ID
      @type
    end
  end
end

class TypeNotID < Nonterminal
  attr_reader :type

  def fill_slots(table_entry)
    @type = table_entry.first
  end
end

class StmtList < Nonterminal
  def fill_slots(table_entry)
    if table_entry.length == 2
      @stmt, @stmt_list = table_entry
    else
      @epsilon = table_entry.first
    end
  end

  def to_ir
    Intermediate::Procedure.new(self.to_ir!)
  end

  def to_ir!
    return [] if self.epsilon?
    [@stmt.to_ir] + @stmt_list.to_ir!
  end
end

class Stmt < Nonterminal
  def fill_slots(table_entry)
    case table_entry.first
    when TypeNotID
      @stmt_type = :init
      @type_not_id, @id, _, @expr, _ = table_entry
    when open_brace_d
      @stmt_type = :block
      _, @stmt_list, _ = table_entry
    when if_rw
      @stmt_type = :ifelse
      _, _, @test, _, @true_case, _, @false_case = table_entry
    when while_rw
      @stmt_type = :while
      _, _, @test, _, @body = table_entry
    when system_out_println_rw
      @stmt_type = :println
      _, _, @print_expr, _, _ = table_entry
    when Lexer::ID
      @stmt_type = :assign
      @id, @stmt_prime_id = table_entry
    end
  end

  def to_ir
    case @stmt_type
    when :init
      Intermediate::InitStatement.new(@type_not_id.type, @id, @expr.to_ir)
    when :block
      Intermediate::BlockStatement.new(@stmt_list.to_ir)
    when :ifelse
      Intermediate::IfElseStatement.new(@test.to_ir, @true_case.to_ir, @false_case.to_ir)
    when :while
      Intermediate::WhileStatement.new(@test.to_ir, @body.to_ir)
    when :println
      Intermediate::PrintlnStatement.new(@print_expr.to_ir)
    when :assign
      @stmt_prime_id.to_ir(@id)
    end
  end
end

class StmtPrimeID < Nonterminal
  def fill_slots(table_entry)
    if table_entry.length == 3
      _, @expr, _ = table_entry
    else
      @id, _, @expr, _ = table_entry
    end
  end

  def to_ir(id)
    if @id.nil?
      Intermediate::AssignStatement.new(id, @expr.to_ir)
    else
      Intermediate::InitStatement.new(id, @id, @expr.to_ir)
    end
  end
end

class Expr < Nonterminal
  def fill_slots(table_entry)
    @expr7, @expr_prime = table_entry
  end

  def to_ir
    @expr_prime.to_ir(@expr7)
  end
end

class ExprPrime < Nonterminal
  def fill_slots(table_entry)
    if table_entry.length == 1
      @epsilon = table_entry.first
    else
      @op, @expr7, @expr_prime = table_entry
    end
  end

  def to_ir(expr7_lhs)
    if self.epsilon?
      expr7_lhs.to_ir
    else
      Intermediate::InfixExpr.new(expr7_lhs.to_ir, @op, @expr_prime.to_ir(@expr7))
    end
  end
end

class Expr7 < Nonterminal
  def fill_slots(table_entry)
    @expr6, @expr7_prime = table_entry
  end

  def to_ir
    @expr7_prime.to_ir(@expr6)
  end
end

class Expr7Prime < Nonterminal
  def fill_slots(table_entry)
    if table_entry.length == 1
      @epsilon = table_entry.first
    else
      @op, @expr6, @expr7_prime = table_entry
    end
  end

  def to_ir(expr6_lhs)
    if self.epsilon?
      expr6_lhs.to_ir
    else
      Intermediate::InfixExpr.new(expr6_lhs.to_ir, @op, @expr7_prime.to_ir(@expr6))
    end
  end
end

class Expr6 < Nonterminal
  def fill_slots(table_entry)
    @expr5, @expr6_prime = table_entry
  end

  def to_ir
    @expr6_prime.to_ir(@expr5)
  end
end

class Expr6Prime < Nonterminal
  def fill_slots(table_entry)
    if table_entry.length == 1
      @epsilon = table_entry.first
    else
      @op, @expr5, @expr6_prime = table_entry
    end
  end

  def to_ir(expr5_lhs)
    if self.epsilon?
      expr5_lhs.to_ir
    else
      Intermediate::InfixExpr.new(expr5_lhs.to_ir, @op, @expr6_prime.to_ir(@expr5))
    end
  end
end

class Expr5 < Nonterminal
  def fill_slots(table_entry)
    @expr4, @expr5_prime = table_entry
  end

  def to_ir
    @expr5_prime.to_ir(@expr4)
  end
end

class Expr5Prime < Nonterminal
  def fill_slots(table_entry)
    if table_entry.length == 1
      @epsilon = table_entry.first
    else
      @op, @expr4, @expr5_prime = table_entry
    end
  end

  def to_ir(expr4_lhs)
    if self.epsilon?
      expr4_lhs.to_ir
    else
      Intermediate::InfixExpr.new(expr4_lhs.to_ir, @op, @expr5_prime.to_ir(@expr4))
    end
  end
end

class Expr4 < Nonterminal
  def fill_slots(table_entry)
    @expr3, @expr4_prime = table_entry
  end

  def to_ir
    @expr4_prime.to_ir(@expr3)
  end
end

class Expr4Prime < Nonterminal
  def fill_slots(table_entry)
    if table_entry.length == 1
      @epsilon = table_entry.first
    else
      @op, @expr3, @expr4_prime = table_entry
    end
  end

  def to_ir(expr3_lhs)
    if self.epsilon?
      expr3_lhs.to_ir
    else
      Intermediate::InfixExpr.new(expr3_lhs.to_ir, @op, @expr4_prime.to_ir(@expr3))
    end
  end
end

class Expr3 < Nonterminal
  def fill_slots(table_entry)
    @expr2, @expr3_prime = table_entry
  end

  def to_ir
    @expr3_prime.to_ir(@expr2)
  end
end

class Expr3Prime < Nonterminal
  def fill_slots(table_entry)
    if table_entry.length == 1
      @epsilon = table_entry.first
    else
      @op, @expr2, @expr3_prime = table_entry
    end
  end

  def to_ir(expr2_lhs)
    if self.epsilon?
      expr2_lhs.to_ir
    else
      Intermediate::InfixExpr.new(expr2_lhs.to_ir, @op, @expr3_prime.to_ir(@expr2))
    end
  end
end

class Expr2 < Nonterminal
  def fill_slots(table_entry)
    @expr2_prime, @expr1 = table_entry
  end

  def to_ir
    @expr2_prime.to_ir(@expr1)
  end
end

class Expr2Prime < Nonterminal
  def fill_slots(table_entry)
    if table_entry.length == 1
      @epsilon = table_entry.first
    else
      @op, @expr2_prime = table_entry
    end
  end

  def to_ir(expr1)
    if self.epsilon?
      expr1.to_ir
    else
      Intermediate::PrefixExpr.new(@op, @expr2_prime.to_ir(expr1))
    end
  end
end

class Expr1 < Nonterminal
  def fill_slots(table_entry)
    @expr0, @expr1_prime = table_entry
  end

  def to_ir
    @expr1_prime.to_ir(@expr0)
  end
end

class Expr1Prime < Nonterminal
  def fill_slots(table_entry)
    if table_entry.length == 1
      @epsilon = table_entry.first
    else
      _, @method, _, @arg_list, _, @expr1_prime = table_entry
    end
  end

  def to_ir(expr0)
    if self.epsilon?
      expr0.to_ir
    else
      @expr1_prime.to_ir!(Intermediate::MethodCallExpr.new(expr0.to_ir, @method, @arg_list.to_ir))
    end
  end

  def to_ir!(expr0)
    if self.epsilon?
      expr0
    else
      @expr1_prime.to_ir!(Intermediate::MethodCallExpr.new(expr0, @method, @arg_list.to_ir))
    end
  end
end

class ArgList < Nonterminal
  def fill_slots(table_entry)
    if table_entry.length == 1
      @epsilon = table_entry.first
    else
      @expr, @arg_list_prime = table_entry
    end
  end

  def to_ir
    return [] if self.epsilon?
    [@expr.to_ir] + @arg_list_prime.to_ir
  end
end

class ArgListPrime < Nonterminal
  def fill_slots(table_entry)
    if table_entry.length == 1
      @epsilon = table_entry.first
    else
      _, @expr, @arg_list_prime = table_entry
    end
  end

  def to_ir
    return [] if self.epsilon?
    [@expr.to_ir] + @arg_list_prime.to_ir
  end
end

class Expr0 < Nonterminal
  def fill_slots(table_entry)
    case table_entry.first
    when Lexer::ID
      @expr_type = :id
      @value = table_entry.first
    when Lexer::Integer
      @expr_type = :integer
      @value = table_entry.first
    when this_rw
      @expr_type = :this
      @value = table_entry.first
    when null_rw
      @expr_type = :null
      @value = table_entry.first
    when true_rw
      @expr_type = :true
      @value = table_entry.first
    when false_rw
      @expr_type = :false
      @value = table_entry.first
    when new_rw
      @expr_type = :init
      _, @class, _, _ = table_entry
    when open_paren_d
      @expr_type = :parens
      _, @expr, _ = table_entry
    end
  end

  def to_ir
    case @expr_type
    when :id
      Intermediate::IDExpr.new(@value)
    when :integer
      Intermediate::IntLiteralExpr.new(@value)
    when :this
      Intermediate::ThisExpr.new()
    when :null
      Intermediate::NullExpr.new()
    when :true, :false
      Intermediate::BooleanLiteral.new(@value)
    when :init
      Intermediate::InitExpr.new(@class)
    when :parens
      @expr.to_ir
    end
  end
end
