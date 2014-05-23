require_relative 'lexer'

module Terminals
  %w{
    class public static
    extends void int boolean
    if else while return null true
    false this new main
    for until break continue
  }.each do |word|
    define_method("#{word}_rw") do
      Lexer::ReservedWord.new(word)
    end
  end

  def string_rw
    Lexer::ReservedWord.new("String")
  end

  def system_out_println_rw
    Lexer::ReservedWord.new("System.out.println")
  end

  %w{
    + - * /
    < <= >= >
    == != && || !
  }.zip(%w{
    add sub mult div
    lt lte gte gt
    eq neq and or bang
  }).each do |(sym, name)|
    define_method("#{name}_o") do
      Lexer::Operator.new(sym)
    end
  end

  %w/; . , = ( ) { } [ ]/.zip(%w{
    semicolon dot comma equals
    open_paren close_paren
    open_brace close_brace
    open_bracket close_bracket
  }).each do |(sym, name)|
    define_method("#{name}_d") do
      Lexer::Delimiter.new(sym)
    end
  end
end
