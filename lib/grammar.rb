require 'set'

module Grammar
  include Terminals

  TERMINALS = Terminals.instance_methods

  PRODUCTIONS = {
    Program => [
      [MainClassDecl, ClassDeclList]
    ],
    MainClassDecl => [
      [
        class_rw,
        Lexer::ID,
        open_brace_d,
        public_rw,
        static_rw,
        void_rw,
        main_rw,
        open_paren_d,
        string_rw,
        open_bracket_d,
        close_bracket_d,
        Lexer::ID,
        close_paren_d,
        open_brace_d,
        StmtList,
        close_brace_d,
        close_brace_d
      ]
    ],
    ClassDeclList => [
      [ClassDecl, ClassDeclList],
      [:epsilon]
    ],
    ClassDecl => [
      [class_rw, Lexer::ID, ClassDeclPrime]
    ],
    ClassDeclPrime => [
      [
        extends_rw,
        Lexer::ID,
        open_brace_d,
        ClassVarDeclList,
        MethodDeclList,
        close_brace_d
      ],
      [
        open_brace_d,
        ClassVarDeclList,
        MethodDeclList,
        close_brace_d
      ]
    ],
    ClassVarDeclList => [
      [ClassVarDecl, ClassVarDeclList],
      [:epsilon]
    ],
    ClassVarDecl => [
      [Type, Lexer::ID, semicolon_d]
    ],
    MethodDeclList => [
      [MethodDecl, MethodDeclList],
      [:epsilon]
    ],
    MethodDecl => [
      public_rw, Type, Lexer::ID,
      open_paren_d, FormalList, close_paren_d,
      open_brace_d,
      StmtList,
      return_rw, Expr, semicolon_d,
      close_brace_d
    ],
    FormalList => [
      [Formal, FormalListPrime],
      [:epsilon]
    ],
    FormalListPrime => [
      [comma_d, Formal, FormalListPrime],
      [:epsilon]
    ],
    Formal => [Type, Lexer::ID],
    Type => [ [int_rw], [boolean_rw], [Lexer::ID] ],
    StmtList => [
      [Stmt, StmtList],
      [:epsilon]
    ],
    Stmt => [
      [Type, Lexer::ID, equals_o, Expr, semicolon_d],
      [open_brace_d, StmtList, close_brace_d],
      [if_rw, open_paren_d, Expr, close_paren_d, Stmt, else_rw, Stmt],
      [while_rw, open_paren_d, expr, close_paren_d, Stmt],
      [system_out_println_rw, open_paren_d, Expr, close_paren_d, semicolon_d],
      [Lexer::ID, equals_o, Expr, semicolon_d]
    ],
    Expr => [ [Expr7, ExprPrime] ],
    ExprPrime => [ [or_o, Expr7, ExprPrime], [:epsilon] ],
    Expr7 => [ [Expr6, Expr7Prime] ],
    Expr7Prime => [ [and_o, Expr6, Expr7Prime], [:epsilon] ],
    Expr6 => [ [Expr5, Expr6Prime] ],
    Expr6Prime => [
      [eq_o, Expr5, Expr6Prime],
      [neq_o, Expr5, Expr6Prime],
      [:epsilon]
    ],
    Expr5 => [ [Expr4, Expr5Prime] ],
    Expr5Prime => [
      [lt_o, Expr4, Expr5Prime],
      [lte_o, Expr4, Expr5Prime],
      [gte_o, Expr4, Expr5Prime],
      [gt_o, Expr4, Expr5Prime],
      [:epsilon]
    ],
    Expr4 => [ [Expr3, Expr4Prime] ],
    Expr4Prime => [
      [add_o, Expr3, Expr4Prime],
      [sub_o, Expr3, Expr4Prime],
      [:epsilon]
    ],
    Expr3 => [ [Expr2, Expr3Prime] ],
    Expr3Prime => [
      [mult_o, Expr2, Expr3Prime],
      [div_o, Expr2, Expr3Prime],
      [:epsilon]
    ],
    Expr2 => [ [Expr2Prime, Expr1] ],
    Expr2Prime => [
      [bang_o, Expr2Prime, Expr1],
      [sub_o, Expr2Prime, Expr1],
      [:epsilon]
    ],
    Expr1 => [ [Expr0, Expr1Prime] ],
    Expr1Prime => [
      [dot_d, Lexer::ID, open_paren_d, ArgList, close_paren_d, Expr1Prime],
      [:epsilon]
    ],
    ArgList => [
      [Expr, ArgListPrime],
      [:epsilon]
    ],
    ArgListPrime => [
      [comma_d, Expr, ArgListPrime],
      [:epsilon]
    ],
    Expr0 => [
      [Lexer::ID],
      [this_rw],
      [Lexer::Integer],
      [null_rw],
      [true_rw],
      [false_rw],
      [new_rw, Lexer::ID, open_paren_d, close_paren_d],
      [open_paren_d, Expr, close_paren_d]
    ]
  }

  PARSE_TABLE = NONTERMINALS.reduce({}) do |parse_table, nonterminal|
    parse_row = Hash.new(:error)
    PRODUCTIONS[nonterminal].each do |production|
      first_plus(nonterminal, production)
    end
    parse_table[nonterminal] = parse_row
    parse_table
  end

  def first_plus(nonterminal, production)
    arr = first(production)
    if arr.include?(:epsilon)
      Set.new(arr + follow(nonterminal))
    else
      Set.new(arr)
    end
  end
end
