require_relative 'lexer'
require_relative 'terminals'
require_relative 'nonterminals'
require_relative 'grammar'

class Parser
  include Terminals

  class ExpandingFocusError

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
    ast = Program.new
    stack = []
    stack.push(:eof)
    stack.push(ast)
    focus = stack.last
    loop do
      printf("focus: %s, word: %s\n", focus, word)
      if focus == :eof and word == :eof
        return [ast, errors]
      elsif terminal?(focus) or focus == :eof
        is_id = word.is_a? Lexer::ID
        is_integer = word.is_a? Lexer::Integer
        if (focus == word)
          stack.pop
          word = tokens.shift
        elsif is_id or is_integer
          focus.input_text = word.input_text
          stack.pop
          word = tokens.shift
        else
          errors << LookingForFocusError.new(focus)
          stack.pop
        end
      else
        table_row = Grammar::PARSE_TABLE[focus.class]
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
          require 'pry'; binding.pry
          errors << ExpandingFocusError.new
        end
      end
      focus = stack.last
    end
  end

  def terminal?(token)
    ([Lexer::ID.new, Lexer::Integer.new] + Grammar::TERMINALS).include?(token)
  end
end
