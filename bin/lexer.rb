require_relative '../lib/lexer'

File.open(ARGV[0]) do |f|
  Lexer.new(f).run.tokens.map do |token|
    puts token.class.name[7..-1] +  ", " + token.input_text
  end
end
