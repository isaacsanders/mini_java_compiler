require_relative 'terminals'

class Nonterminal
  include Terminals
end

class Program < Nonterminal
  def fill_slots(table_entry)
    @main_class_decl, @class_decl_list = table_entry
  end
end

class MainClassDecl < Nonterminal
  def fill_slots(table_entry)
    _, @id, _, _, _, _, _, _, _, _, _, @arg_id, _, _, @stmt_list, _, _ = table_entry
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
end

class ClassDecl < Nonterminal
  def fill_slots(table_entry)
    _, @id, @class_decl_prime = table_entry
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
end

class ClassVarDeclList < Nonterminal
  def fill_slots(table_entry)
    if table_entry.length == 1
      @epsilon = table_entry.first
    else
      @class_var_decl, @class_var_decl_list = table_entry
    end
  end
end

class ClassVarDecl < Nonterminal
  def fill_slots(table_entry)
    @type, @id, _ = table_entry
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
end

class MethodDecl < Nonterminal
  def fill_slots(table_entry)
    _, @type, @id, _, @formal_list, _, _, @stmt_list, _, @expr, _, _ = table_entry
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
end

class FormalListPrime < Nonterminal
  def fill_slots(table_entry)
    if table_entry.length == 1
      @epsilon = table_entry.first
    else
      _, @formal, @formal_list_prime = table_entry
    end
  end
end

class Formal < Nonterminal
  def fill_slots(table_entry)
    @type, @id = table_entry
  end
end

class Type < Nonterminal
  def fill_slots(table_entry)
    @type = table_entry.first
  end
end

class TypeNotID < Nonterminal
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

  def print_tree(nesting)
    spacing = spacing(nesting)
    if epsilon?
      print("|#{spacing} └-- (epsilon)\n")
    else
      print("|#{spacing} └-- StmtList\n")
      @stmt.print_tree(nesting + 1)
      @stmt_list.print_tree(nesting + 1)
    end
  end
end

class Stmt < Nonterminal
  def fill_slots(table_entry)
    case table_entry.first
    when TypeNotID
      @type_not_id, @id, _, @expr, _ = table_entry
    when open_brace_d
      _, @stmt_list, _ = table_entry
    when if_rw
      _, _, @test, _, @true_case, _, @false_case = table_entry
    when while_rw
      _, _, @test, _, @body = table_entry
    when system_out_println_rw
      _, _, @print_expr, _, _ = table_entry
    when Lexer::ID
      @id, @stmt_prime_id = table_entry
    end
  end

  def print_tree(nesting)
    spacing = spacing(nesting)
    case instance_variables
    when [:@type_not_id, :@id, :@expr]
    when [:@stmt_list]
    when [:@test, :@true_case, :@false_case]
    when [:@test, :@body]
    when [:@print_expr]
    when [:@id, :@stmt_prime_id]
      if @stmt_prime_id.instance_variables.length == 2
        print("|#{spacing} └-- DeclarationStmt:(#{id}) #{@stmt_prime_id.id}\n")
        @stmt_prime_id.print_tree(nesting + 1, nesting)
      else
        print("|#{spacing} └-- AssignmentStmt:#{id}\n")
        @stmt_prime_id.print_tree(nesting + 1)
      end
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
end

class Expr < Nonterminal
  def fill_slots(table_entry)
    @expr7, @expr_prime = table_entry
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
end

class Expr7 < Nonterminal
  def fill_slots(table_entry)
    @expr6, @expr7_prime = table_entry
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
end

class Expr6 < Nonterminal
  def fill_slots(table_entry)
    @expr5, @expr6_prime = table_entry
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

  def print_tree(nesting)
    spacing = spacing(nesting)
    if not epsilon?
      print("|#{spacing} └-- AND\n")
    end
    @expr7.print_tree(nesting + 1)
    @expr_prime.print_tree(nesting + 1)
  end
end

class Expr5 < Nonterminal
  def fill_slots(table_entry)
    @expr4, @expr5_prime = table_entry
  end

  def print_tree(nesting)
    spacing = spacing(nesting)
    print("|#{spacing} └-- Expr6\n")
    @expr6.print_tree(nesting + 1)
    @expr7_prime.print_tree(nesting + 1)
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
end

class Expr4 < Nonterminal
  def fill_slots(table_entry)
    @expr3, @expr4_prime = table_entry
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
end

class Expr3 < Nonterminal
  def fill_slots(table_entry)
    @expr2, @expr3_prime = table_entry
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
end

class Expr2 < Nonterminal
  def fill_slots(table_entry)
    @expr2_prime, @expr1 = table_entry
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
end

class Expr1 < Nonterminal
  def fill_slots(table_entry)
    @expr0, @expr1_prime = table_entry
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
end

class ArgList < Nonterminal
  def fill_slots(table_entry)
    if table_entry.length == 1
      @epsilon = table_entry.first
    else
      @expr, @arg_list_prime = table_entry
    end
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
end

class Expr0 < Nonterminal
  def fill_slots(table_entry)
    case table_entry.first
    when Lexer::ID, Lexer::Integer
      @value = table_entry.first
    when this_rw, null_rw, true_rw, false_rw
      @value = table_entry.first
    when new_rw
      _, @class, _, _ = table_entry
    when open_paren_d
      _, @expr, _ = table_entry
    end
  end
end
