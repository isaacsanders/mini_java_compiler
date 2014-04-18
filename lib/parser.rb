require_relative 'lexer'
require_relative 'terminals'
require_relative 'nonterminals'
require_relative 'grammar'

class Parser
  include Terminals

  class ExpandingFocusError
    def initialize(focus, word)
      @focus, @word = focus, word
    end
  end

  class LookingForFocusError
    def initialize(focus)
      @focus = focus
    end
  end

  def initialize(tokens)
    @tokens = tokens
  end

  def parse
    tokens = @tokens.dup
    errors = []
    word = tokens.shift
    parse_tree = Program.new
    stack = []
    stack.push(:eof)
    stack.push(parse_tree)
    focus = stack.last
    loop do
      if focus == :eof and word == :eof
        return [parse_tree, errors]
      elsif terminal?(focus) or focus == :eof
        is_id = focus.is_a?(Lexer::ID) && word.is_a?(Lexer::ID)
        is_integer = focus.is_a?(Lexer::Integer) && word.is_a?(Lexer::Integer)
        if (focus == word)
          # printf("[SAME] %s\n", word)
          stack.pop
          word = tokens.shift
        elsif is_id or is_integer
          focus.input_text = word.input_text
          # printf("[INPUT] %s\n", word)
          stack.pop
          word = tokens.shift
        else
          # printf("[ERROR] focus: %s, word: %s\n", focus, word)
          errors << LookingForFocusError.new(focus)
          word = tokens.shift unless word == :eof
          stack.pop unless focus == :eof
        end
      else
        table_row = Grammar::PARSE_TABLE[focus.class]
        # printf("[RULE] focus: %s, word: %s\n", focus, word)
        if [Lexer::ID, Lexer::Integer].any? {|t| word.kind_of? t }
          table_entry = table_row[word.class]
        else
          table_entry = table_row[word]
        end
        if table_entry.is_a? Array
          stack.pop
          slots = []
          table_entry.reverse.each do |token|
            if token != :epsilon
              if token.is_a? Class
                if token < Nonterminal or token < Lexer::Token
                  node = token.new
                  slots.unshift(node)
                  stack.push(node)
                end
              else
                slots.unshift(token)
                stack.push(token)
              end
            else
              slots.unshift(token)
            end
          end
          focus.fill_slots(slots)
        else
          stack.pop
          errors << ExpandingFocusError.new(focus, word)
        end
      end
      focus = stack.last
    end
  end

  def terminal?(token)
    ([Lexer::ID.new, Lexer::Integer.new] + Grammar::TERMINALS).include?(token)
  end
end
