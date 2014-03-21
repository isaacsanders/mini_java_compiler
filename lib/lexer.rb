class Lexer
  token = Struct.new(:input_text)
  ID = Class.new(token)
  Integer = Class.new(token)
  ReservedWord = Class.new(token)
  Operator = Class.new(token)
  Delimiter = Class.new(token)
  attr_reader :file

  def initialize(file)
    @file = file
  end

  def get_tokens
    state = :start
    input = ""
    tokens = []
    until file.eof?
      char = file.readchar if char.nil?
      case state
      when :start
        #======================================================================
        # Start State
        #======================================================================
        case char
        when "\t", " ", "\n", "\r"
          #====================================================================
          # Whitespace, nothing special
          #====================================================================
          tokens << input unless input.empty?
          input = ""
          char = nil
        when "/"
          #====================================================================
          # Could be a comment or a delimiter
          #====================================================================
          tokens << input unless input.empty?
          input = char
          state = :forward_slash
          char = nil
        else
          #====================================================================
          # token stage
          #====================================================================
          input << char
          state = :token_start
        end
      when :token_start
        #======================================================================
        # It isn't whitespace, must be a token
        #======================================================================
        case char
        when 'c'
          #====================================================================
          # Tokens starting with 'c' might be "class" or an ID
          #====================================================================
          state = :token_c
        when 'p'
          #====================================================================
          # Tokens starting with 'p' might be "public" or an ID
          #====================================================================
          state = :token_c
        when 's'
          #====================================================================
          # Tokens starting with 's' might be "static" or an ID
          #====================================================================
          state = :token_s
        when 'e'
          #====================================================================
          # Tokens starting with 'e' might be "extends", "else", or an ID
          #====================================================================
          state = :token_e
        when 'v'
          #====================================================================
          # Tokens starting with 'v' might be "void" or an ID
          #====================================================================
          state = :token_v
        when 'i'
          #====================================================================
          # Tokens starting with 'i' might be "int", "if", or an ID
          #====================================================================
          state = :token_i
        when 'b'
          #====================================================================
          # Tokens starting with 'b' might be "boolean" or an ID
          #====================================================================
          state = :token_b
        when 'w'
          #====================================================================
          # Tokens starting with 'w' might be "while" or an ID
          #====================================================================
          state = :token_w
        when 'r'
          #====================================================================
          # Tokens starting with 'r' might be "return" or an ID
          #====================================================================
          state = :token_r
        when 'n'
          #====================================================================
          # Tokens starting with 'n' might be "null", "new", or an ID
          #====================================================================
          state = :token_n
        when 't'
          #====================================================================
          # Tokens starting with 't' might be "true", "this", or an ID
          #====================================================================
          state = :token_t
        when 'f'
          #====================================================================
          # Tokens starting with 'n' might be "false" or an ID
          #====================================================================
          state = :token_f
        when 'S'
          #====================================================================
          # Tokens starting with 'n' might be "String", "System.out.println",
          # or an ID
          #====================================================================
          state = :token_S
        when 'm'
          #====================================================================
          # Tokens starting with 'm' might be "main" or an ID
          #====================================================================
          state = :token_m
        when '0'
          #====================================================================
          # This is a 0
          #====================================================================
          input = ''
          tokens << Integer.new(char)
          state = :start
          char = nil
        when '1'..'9'
          #====================================================================
          # This is the beginning of a non-zero integer
          #====================================================================
          input << char
          state = :nonzero_integer
          char = nil
        when '+', '-', '*'
        when '<'
        when '>'
        when '='
        when '!'
        when '&'
        when '|'
        when ';', '.', ',', '(', ')', '{', '}', '[', ']'
          #====================================================================
          # We have a delimiter
          #====================================================================
          tokens << Delimiter.new(char)
          raise 'hell' unless input.empty?
          char = nil
          state = :start
        else
          #====================================================================
          # We might have an ID, or an invalid symbol
          #====================================================================
          input << char
          state = :id
          char = nil
        end
      when :forward_slash
        #======================================================================
        # We have just seen a forward slash
        #======================================================================
        case char
        when "/"
          #====================================================================
          # This is an inline comment
          #====================================================================
          input = ""
          char = file.readchar until char =~ /[\n\r]/
          state = :start
        when "*"
          #====================================================================
          # This is the opening of a block comment
          #====================================================================
          input = ""
          state = :block_comment
        else
          #====================================================================
          # We found a / delimiter. Back to normal business.
          #====================================================================
          tokens << Delimiter.new(input)
          input = char
          state = :start
        end
        char = nil
      when :block_comment
        #======================================================================
        # Inside a block comment
        #======================================================================
        case char
        when "*"
          #====================================================================
          # Could be the end of a block comment
          #====================================================================
          char = file.readchar
          if char == "/"
            input = ""
            state = :start
          end
        end
        char = nil
      end
    end
    tokens
  end
end
