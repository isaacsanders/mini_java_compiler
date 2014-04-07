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

      ]
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
