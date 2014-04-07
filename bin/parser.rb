#!/usr/bin/ruby

require_relative '../lib/lexer'
require_relative '../lib/parser'

File.open(ARGV[0]) do |f|
  tokens = Lexer.new(f).run.tokens
  tree = Parser.new(tokens).run.tree
  tree.print
end
