require_relative '../lib/lexer'

File.open(ARGV[0]) do |f|
  Lexer.new(f).run.tokens.each do |token|
    if token != :eof
      puts token.class.name[7..-1] +  ", " + token.input_text
    end
  end
end
