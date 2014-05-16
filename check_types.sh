ruby -r awesome_print -r ./lib/parser.rb -e "errors = Parser.new(Lexer.new(File.new(ARGV[0])).run.tokens).run.parse_tree.to_ir.check_types; puts errors.empty? ? 'Success!' : errors.map(&:message)" $1
