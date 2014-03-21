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
    errors = []
    lineno = 1
    column = 0
    char = nil
    until file.eof?
      if char.nil?
        char = file.readchar
        column += 1
      end

      case state
      when :start, :id, :forward_slash, :block_comment, :reserved_word
      else
        input << char
      end

      printf %{%s "%s" '%s'\n}, state, input, char
      case state
      when :start
        #======================================================================
        # Start State
        #======================================================================
        case char
        when "\n", "\r"
          lineno += 1
          column = 0
          char = nil
        when "\t", " "
          #====================================================================
          # Whitespace, nothing special
          #====================================================================
          char = nil
        when "/"
          #====================================================================
          # Could be a comment or a delimiter
          #====================================================================
          char = nil
          state = :forward_slash
        else
          #====================================================================
          # token stage
          #====================================================================
          state = :start_token
        end
      when :start_token
        #======================================================================
        # It isn't whitespace, must be a token
        #======================================================================
        case char
        when /[a-zA-Z]/
          state = :identifier_or_reserved
          reserved_tree = self.get_reserved_tree(char)
          input = char
          char = nil
        when '0'
          #====================================================================
          # This is a 0
          #====================================================================
          input = ''
          tokens << Integer.new(char)
          state = :start
        when '1'..'9'
          #====================================================================
          # This is the beginning of a non-zero integer
          #====================================================================
          state = :nonzero_integer
        when '+', '-', '*'
          #====================================================================
          # This is an operator
          #====================================================================
          tokens << Operator.new(char)
          state = :start
        when '<'
          #====================================================================
          # This may be a "<" or a "<="
          #====================================================================
          state = :less_than
        when '>'
          #====================================================================
          # This may be a ">" or a ">="
          #====================================================================
          state = :greater_than
        when '='
          #====================================================================
          # This may be a "=" or a "=="
          #====================================================================
          state = :equals
        when '!'
          #====================================================================
          # This may be a "!" or a "!="
          #====================================================================
          state = :shebang
        when '&'
          #====================================================================
          # This needs to be followed by another &, or there is an error
          #====================================================================
          state = :ampersand
        when '|'
          #====================================================================
          # This needs to be followed by another |, or there is an error
          #====================================================================
          state = :pipe
        when ';', '.', ',', '(', ')', '{', '}', '[', ']'
          #====================================================================
          # We have a delimiter
          #====================================================================
          input = ''
          tokens << Delimiter.new(char)
          state = :start
        when 'a'..'z', 'A'..'Z'
          state = :id
        else
          #====================================================================
          # We might have an ID, or an invalid symbol
          #====================================================================
          errors << [lineno, column, "Invalid Symbol"]
          input = ''
          state = :start
        end
        char = nil
      when :identifier_or_reserved
        nextregex = reserved_tree.nextregex
        case char
        when nextregex
          # on track to a reserved word
          reserved_tree = reserved_tree.next(char)
          input << char
          char = nil
          # stay in this state unless at the end of word
          if reserved_tree.at_word
            state = :reserved_word
        when /[a-zA-Z0-9/
          # not a reserved word
          # some other identifier
          state = :id
        else
          # not a reserved word
          # identifier is complete
          state = :id
      when :reserved_word
        case char
        when /[a-zA-Z0-9]/
          # identifier (or other reserved word) prefixed with reserved word
          state = :identifier_or_reserved
        else
          tokens << ReservedWord.new(input)
          input = ''
          state = :start
      when :id
        #======================================================================
        # ID token
        #======================================================================
        case char
        when 'a'..'z', 'A'..'Z', '0..9'
          input << char
          char = nil
        else
          tokens << ID.new(input)
          input = ''
          state = :start
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
          lineno += 1
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
          tokens << Delimiter.new('/')
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
        when "\n", "\r"
          lineno += 1
        end
        char = nil
      else
        raise [state.to_s, input, char].to_s
      end
    end
    [tokens, errors]
  end
end
