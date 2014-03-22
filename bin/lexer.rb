require_relative '../lib/lexer'

File.open(ARGV[0]) do |f|
  Lexer.new(f).get_tokens()[0].map do |token|
    puts token.class.name[7..-1] +  ", " + token[0]
  end;
end
