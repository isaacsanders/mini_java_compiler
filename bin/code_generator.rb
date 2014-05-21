#!/usr/bin/ruby

require_relative '../lib/lexer'
require_relative '../lib/parser'

File.open(ARGV[0]) do |f|
  tokens = Lexer.new(f).run.tokens
  parser = Parser.new(tokens).run

  if parser.errors.empty?
    tree = parser.parse_tree
    ast = tree.to_ir
    type_errors = ast.check_types

    if type_errors.empty?
      puts ast.to_mips
    else
      puts type_errors.map(&:message)
    end
  else
    puts parser.errors
  end
end
