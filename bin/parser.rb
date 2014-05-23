#!/usr/bin/ruby

require_relative '../lib/lexer'
require_relative '../lib/parser'
require "awesome_print"

File.open(ARGV[0]) do |f|
  tokens = Lexer.new(f).run.tokens
  tree = Parser.new(tokens).run.parse_tree
  ap tree.to_ir, { raw: true, indent: 2 }
end
