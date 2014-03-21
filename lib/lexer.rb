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
        when 'c'
          #====================================================================
          # Tokens starting with 'c' might be "class" or an ID
          #====================================================================
          state = :token_c
        when 'p'
          #====================================================================
          # Tokens starting with 'p' might be "public" or an ID
          #====================================================================
          state = :token_p
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
        #======================================================================
        # "class" states
        #======================================================================
      when :token_c
        case char
        when 'l' then state = :token_cl
        else state = :id
        end
        char = nil
      when :token_cl
        case char
        when 'a' then state = :token_cla
        else state = :id
        end
        char = nil
      when :token_cla
        case char
        when 's' then state = :token_clas
        else state = :id
        end
        char = nil
      when :token_clas
        case char
        when 's' then state = :reserved_word
        else state = :id
        end
        char = nil
        #======================================================================
        # "public" states
        #======================================================================
      when :token_p
        case char
        when 'u' then state = :token_pu
        else state = :id
        end
        char = nil
      when :token_pu
        case char
        when 'b' then state = :token_pub
        else state = :id
        end
        char = nil
      when :token_pub
        case char
        when 'l' then state = :token_publ
        else state = :id
        end
        char = nil
      when :token_publ
        case char
        when 'i' then state = :token_publi
        else state = :id
        end
        char = nil
      when :token_publi
        case char
        when 'c' then state = :reserved_word
        else state = :id
        end
        char = nil
        #======================================================================
        # "static" states
        #======================================================================
      when :token_s
        case char
        when 't' then state = :token_st
        else state = :id
        end
        char = nil
      when :token_st
        case char
        when 'a' then state = :token_sta
        else state = :id
        end
        char = nil
      when :token_sta
        case char
        when 't' then state = :token_stat
        else state = :id
        end
        char = nil
      when :token_stat
        case char
        when 'i' then state = :token_stati
        else state = :id
        end
        char = nil
      when :token_stati
        case char
        when 'c' then state = :reserved_word
        else state = :id
        end
        char = nil
        #======================================================================
        # "extends" states
        #======================================================================
      when :token_e
        case char
        when 'x' then state = :token_ex
        else state = :id
        end
        char = nil
      when :token_ex
        case char
        when 't' then state = :token_ext
        else state = :id
        end
        char = nil
      when :token_ext
        case char
        when 'e' then state = :token_exte
        else state = :id
        end
        char = nil
      when :token_exte
        case char
        when 'n' then state = :token_exten
        else state = :id
        end
        char = nil
      when :token_exten
        case char
        when 'd' then state = :token_extend
        else state = :id
        end
        char = nil
      when :token_extend
        case char
        when 's' then state = :reserved_word
        else state = :id
        end
        char = nil
        #======================================================================
        # "void" states
        #======================================================================
      when :token_v
        case char
        when 'o' then state = :token_vo
        else state = :id
        end
        char = nil
      when :token_vo
        case char
        when 'i' then state = :token_voi
        else state = :id
        end
        char = nil
      when :token_voi
        case char
        when 'd' then state = :reserved_word
        else state = :id
        end
        char = nil
        #======================================================================
        # "int" states
        #======================================================================
      when :token_i
        case char
        when 'n' then state = :token_in
        else state = :id
        end
        char = nil
      when :token_in
        case char
        when 't' then state = :reserved_word
        else state = :id
        end
        char = nil
        #======================================================================
        # "boolean" states
        #======================================================================
      when :token_b
        case char
        when 'o' then state = :token_bo
        else state = :id
        end
        char = nil
      when :token_bo
        case char
        when 'o' then state = :token_boo
        else state = :id
        end
        char = nil
      when :token_boo
        case char
        when 'l' then state = :token_bool
        else state = :id
        end
        char = nil
      when :token_bool
        case char
        when 'e' then state = :token_boole
        else state = :id
        end
        char = nil
        #======================================================================
        # "this" states
        #======================================================================
      when :token_t
        case char
        when 'r' then state = :token_tr
        when 'h' then state = :token_th
        else state = :id
        end
        char = nil
      when :token_th
        case char
        when 'i' then state = :token_thi
        else state = :id
        end
        char = nil
      when :token_thi
        case char
        when 's' then state = :reserved_word
        else state = :id
        end
        char = nil
      when :reserved_word
        case char
        when "\t", " ", "\n", "\r"
          tokens << ReservedWord.new(input)
          input = ''
          state = :start
        else
          state = :id
        end
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
