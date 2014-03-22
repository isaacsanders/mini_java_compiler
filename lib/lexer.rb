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
    @reserved_tree = ReservedTree.new(['class','public','static','extends','void','int','boolean','if','else','while','return','return','null','true','false','this','new','String','main','System.out.println'])
  end

  def set_reserved_words(list_of_words)
    @reserved_tree = ReservedTree.new(list_of_words)
  end

  def get_tokens
    state = :start
    input = ""
    tokens = []
    errors = []
    lineno = 1
    column = 0
    char = nil
    reserved_tree = nil
    begin
      if char.nil?
        char = file.readchar
        column += 1
      end


      case state
      when :start, :id, :identifier_or_reserved, :forward_slash, :block_comment, :reserved_word, :one_or_two_char_operator
      else
        input << char
      end

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
          # Could be a comment or an operator
          #====================================================================
          char = nil
          state = :forward_slash
        when 'a'..'z', 'A'..'Z'
          state = :identifier_or_reserved
          reserved_tree = @reserved_tree # instance var resets tree
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
          input = ''
          state = :start
        when '<','>','!'
          #====================================================================
          # This may be a "<" or a "<="
          #               ">"      ">="
          #               "!"      "!="
          #====================================================================
          state = :one_or_two_char_operator
          char = ''
        when '='
          #====================================================================
          # This may be a "=" or a "=="
          #====================================================================
          state = :equals
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
        else
          #====================================================================
          # We might have an ID, or an invalid symbol
          #====================================================================
          errors << [lineno, column, "Invalid Symbol"]
          input = ''
          state = :start
        end
        char = nil
      when :nonzero_integer
        case char
        when '0'..'9'
          char = nil
        else
          tokens << Integer.new(input[0..-2])
          input = input[-1]
          state = :start
        end
      when :identifier_or_reserved
        reserved_tree = reserved_tree.next(char)
        if reserved_tree
          # on track to a reserved word
          input << char
          char = nil
          # stay in this state unless at the end of word
          if reserved_tree.is_accepting
            state = :reserved_word
          end
        else
          # not a reserved word
          state = :id
        end
      when :ampersand
        case char
        when '&'
          tokens << Operator.new(input)
          char = nil
          state = :start
        else
          errors << [lineno, column, "Invalid syntax '&'"]
          input = ''
          char = nil
          state = :start
        end
        #======================================================================
        # "<", "<=", ">", ">=", "=", "==", "!", "!=" states
        #======================================================================
      when :one_or_two_char_operator
        case char
        when '='
          # add = to the operator
          input << char
          char = nil
        else
          # do not consume current char
        end
        tokens << Operator.new(input)
        input = ''
        state = :start
      when :equals
        case char
        when '='
          tokens << Operator.new(input)
          char = nil
        else
          tokens << Delimiter.new('=')
        end
        input = ''
        state = :start
      when :token_Sy
        case char
        when 's' then state = :token_Sys
        else state = :id
        end
        char = nil
      when :token_Sys
        case char
        when 't' then state = :token_Syst
        else state = :id
        end
        char = nil
      when :token_Syst
        case char
        when 'e' then state = :token_Syste
        else state = :id
        end
        char = nil
      when :token_Syste
        case char
        when 'm' then state = :token_System
        else state = :id
        end
        char = nil
      when :token_System
        case char
        when '.' then state = :token_System_dot
        else
          tokens << ID.new("System")
          input = char
          state = :id
        end
        char = nil
      when :token_System_dot
        case char
        when 'o' then state = :token_System_dot_o
        else
          tokens << ID.new("System")
          tokens << Delimiter.new('.')
          input = char
          state = :id
        end
        char = nil
      when :token_System_dot_o
        case char
        when 'u' then state = :token_System_dot_ou
        else
          tokens << ID.new("System")
          tokens << Delimiter.new('.')
          input = 'o' + char
          state = :id
        end
        char = nil
      when :token_System_dot_ou
        case char
        when 't' then state = :token_System_dot_out
        else
          tokens << ID.new("System")
          tokens << Delimiter.new('.')
          input = 'ou' + char
          state = :id
        end
        char = nil
      when :token_System_dot_out
        case char
        when '.' then state = :token_System_dot_out_dot
        else
          tokens << ID.new("System")
          tokens << Delimiter.new('.')
          input = 'out' + char
          state = :id
        end
        char = nil
      when :token_System_dot_out_dot
        case char
        when 'p' then state = :token_System_dot_out_dot_p
        else
          tokens << ID.new("System")
          tokens << Delimiter.new('.')
          tokens << ID.new("out")
          tokens << Delimiter.new('.')
          input = char
          state = :id
        end
        char = nil
      when :token_System_dot_out_dot_p
        case char
        when 'r' then state = :token_System_dot_out_dot_pr
        else
          tokens << ID.new("System")
          tokens << Delimiter.new('.')
          tokens << ID.new("out")
          tokens << Delimiter.new('.')
          input = 'p' + char
          state = :id
        end
        char = nil
      when :token_System_dot_out_dot_pr
        case char
        when 'i' then state = :token_System_dot_out_dot_pri
        else
          tokens << ID.new("System")
          tokens << Delimiter.new('.')
          tokens << ID.new("out")
          tokens << Delimiter.new('.')
          input = 'pr' + char
          state = :id
        end
        char = nil
      when :token_System_dot_out_dot_pri
        case char
        when 'n' then state = :token_System_dot_out_dot_prin
        else
          tokens << ID.new("System")
          tokens << Delimiter.new('.')
          tokens << ID.new("out")
          tokens << Delimiter.new('.')
          input = 'pri' + char
          state = :id
        end
        char = nil
      when :token_System_dot_out_dot_prin
        case char
        when 't' then state = :token_System_dot_out_dot_print
        else
          tokens << ID.new("System")
          tokens << Delimiter.new('.')
          tokens << ID.new("out")
          tokens << Delimiter.new('.')
          input = 'prin' + char
          state = :id
        end
        char = nil
      when :token_System_dot_out_dot_print
        case char
        when 'l' then state = :token_System_dot_out_dot_printl
        else
          tokens << ID.new("System")
          tokens << Delimiter.new('.')
          tokens << ID.new("out")
          tokens << Delimiter.new('.')
          input = 'print' + char
          state = :id
        end
        char = nil
      when :token_System_dot_out_dot_printl
        case char
        when 'n' then state = :reserved_word
        else
          tokens << ID.new("System")
          tokens << Delimiter.new('.')
          tokens << ID.new("out")
          tokens << Delimiter.new('.')
          input = 'printl' + char
          state = :id
        end
        char = nil
      when :reserved_word
        case char
        when /[a-zA-Z0-9]/
          # identifier (or other reserved word) prefixed with reserved word
          state = :identifier_or_reserved
        else
          tokens << ReservedWord.new(input)
          input = ''
          state = :start
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
          # We found a / operator. Back to normal business.
          #====================================================================
          tokens << Operator.new('/')
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
    rescue EOFError
      [[],[]]
    end until @file.eof?
    @file.close
    [tokens, errors]
  end

  def print
    tokens, errors = get_tokens
    tokens.each do |token|
      printf "%s, %s\n", token.class.name.split("::")[-1], token.input_text
    end
  end
end

class ReservedTree
  attr_reader :is_accepting

  # recursively initializes a tree of words where
  # each ReservedTree is a node
  def initialize(reserved_words)
    @is_accepting = false
    @children = Hash.new()
    mapping = Hash.new([])
    reserved_words.each do |word|
      firstchar = word[0]
      if firstchar
        mapping[firstchar] += [word[1..-1]]
      else
        # word is empty string
        @is_accepting = true
      end
    end
    mapping.each do |firstchar, words|
      # words is a list of words that begin with the
      # firstchar, but with that char removed
      @children[firstchar] = ReservedTree.new(words)
    end
  end

  def next(char)
    return @children[char]
  end

  def has_next?(char)
    return @children.has_key? char
  end

end
