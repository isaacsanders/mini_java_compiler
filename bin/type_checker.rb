#!/usr/bin/ruby

require_relative '../lib/lexer'
require_relative '../lib/parser'
require_relative "../lib/nonterminals"

File.open(ARGV[0]) do |f|
  tokens = Lexer.new(f).run.tokens
  tree = Parser.new(tokens).run.parse_tree
  ast = tree.to_ir
  type_errors = ast.check_types
  if type_errors.empty?
    p ast.to_mips
  else
    p type_errors
  end
end
