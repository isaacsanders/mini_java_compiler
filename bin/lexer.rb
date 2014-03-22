require_relative '../lib/lexer'

File.open(ARGV[0]) do |f|
  puts Lexer.new(f).get_tokens();
end
