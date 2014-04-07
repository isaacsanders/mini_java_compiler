require_relative 'lexer'

class Parser
  include Terminals


  def initialize(tokens)
    @tokens = tokens
  end

  def parse
    tokens = @tokens.dup
    errors = []
    word = tokens.shift

    stack.push(:eof)
    stack.push(Program)
    focus = stack.last
    loop do
      if focus == :eof and word == :eof
        return [ast, errors]
      elsif TERMINALS.include?(focus) or focus == :eof
        if focus == word
          stack.pop
          word = tokens.shift
        else
          errors << LookingForFocusError.new(focus)
        end
      else
        table_entry = PARSE_TABLE[focus]
        if table_entry.is_a? Array
          stack.pop
          table_entry.each do |token|
            stack.push(token)
          end
        else
          errors << ExpandingFocusError.new
        end
      end
    end
  end
end
