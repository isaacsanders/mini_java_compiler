require_relative '../lib/simple_lexer'

File.open(ARGV[0]) do |f|
  puts SimpleLexer.new.run(f.read.chomp)
end
