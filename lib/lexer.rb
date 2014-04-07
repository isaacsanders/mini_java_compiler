class Lexer
  Token = Struct.new(:input_text)
  ID = Class.new(Token)
  Integer = Class.new(Token)
  ReservedWord = Class.new(Token)
  Operator = Class.new(Token)
  Delimiter = Class.new(Token)
  attr_reader :file, :errors, :tokens

  def initialize(file)
    @file = file
    @reserved_tree = ReservedTree.new(['class','public','static','extends','void','int','boolean','if','else','while','return','return','null','true','false','this','new','String','main'])
  end

  def set_reserved_words(list_of_words)
    @reserved_tree = ReservedTree.new(list_of_words)
  end

  def run
    state = :start
    input = ""
    tokens = []
    errors = []
    lineno = 1
    column = 0
    char = nil
    reserved_tree = nil
    is_done = false
    begin
      if char.nil?
        begin
          char = file.readchar
          column += 1
        rescue EOFError
          char = :eof
        end
      end


      case state
      when :start, :id, :identifier_or_reserved, :forward_slash, :block_comment, :reserved_word, :one_or_two_char_operator, :equals, :nonzero_integer
      else
        input << char unless char == :eof
      end

      case state
      when :start
        #======================================================================
        # Start State
        #======================================================================
        case char
        when :eof
          is_done = true
        when "\n", "\r"
          lineno += 1
          column = 0
          char = nil
          input = '' # it should already be blank (otherwise there's a bug)
        when "\t", " "
          #====================================================================
          # Whitespace, nothing special
          #====================================================================
          char = nil
          input = '' # it should already be blank (otherwise there's a bug)
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
        when 'S'
          state = :token_S
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
          char = nil
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
          char = nil
        when '='
          #====================================================================
          # This may be a "=" or a "=="
          #====================================================================
          state = :equals
          char = nil
        when '&', '|'
          #====================================================================
          # This needs to be followed by itself, or there is an error
          #====================================================================
          state = :ampersand_or_pipe
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
          input << char
          char = nil
        else
          tokens << Integer.new(input)
          input = ''
          state = :start
          # we haven't used the char
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
        elsif input == "S" and char == "y"
          # hook for System.out.println workaround
          state = :token_Sy
          input << char
          char = nil
        else
          # not a reserved word
          state = :id
        end
      when :ampersand_or_pipe
        case input
        when '&&', '||' # existing pipe or ampersand
          tokens << Operator.new(input)
          char = nil
          input = ''
          state = :start
        else
          errors << [lineno, column, "Invalid syntax '#{input}'"]
          input = '' # throw out our existing '&' or '|'
          state = :start
          # keep non-& or non-| char for next token
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
          input << char
          tokens << Operator.new(input) # '=='
          char = nil
        else
          tokens << Delimiter.new('=')
          # don't clear char
        end
        input = ''
        state = :start
      when :token_S
        case char
        when 'y'
          state = :token_Sy
          char = nil
        when 'a'..'z', 'A'..'Z', '0'..'9'
          state = :id
          char = nil
        else
          tokens << ID.new('S')
          input = ''
          state = :start
        end
      when :token_Sy
        case char
        when 's'
          state = :token_Sys
          char = nil
        when 'a'..'z', 'A'..'Z', '0'..'9'
          state = :id
          char = nil
        else
          tokens << ID.new('Sy')
          input = ''
          state = :start
        end
      when :token_Sys
        case char
        when 't'
          state = :token_Syst
          char = nil
        when 'a'..'z', 'A'..'Z', '0'..'9'
          state = :id
          char = nil
        else
          tokens << ID.new('Sys')
          input = ''
          state = :start
        end
      when :token_Syst
        case char
        when 'e'then state = :token_Syste
          state = :token_Syste
          char = nil
        when 'a'..'z', 'A'..'Z', '0'..'9'
          state = :id
          char = nil
        else
          tokens << ID.new('Syst')
          input = ''
          state = :start
        end
      when :token_Syste
        case char
        when 'm' then state = :token_System
          state = :token_System
          char = nil
        when 'a'..'z', 'A'..'Z', '0'..'9'
          state = :id
          char = nil
        else
          tokens << ID.new('Syste')
          input = ''
          state = :start
        end
      when :token_System
        case char
        when '.'
          state = :token_System_dot
          char = nil
        when 'a'..'z', 'A'..'Z', '0'..'9'
          state = :id
          char = nil
        else
          tokens << ID.new("System")
          input = ''
          state = :start
        end
      when :token_System_dot
        case char
        when 'o'
          state = :token_System_dot_o
          char = nil
        when 'a'..'z', 'A'..'Z', '0'..'9'
          tokens << ID.new("System")
          tokens << Delimiter.new('.')
          input = char
          state = :id
          char = nil
        else
          tokens << ID.new("System")
          tokens << Delimiter.new('.')
          input = ''
          state = :start
        end
      when :token_System_dot_o
        case char
        when 'u'
          state = :token_System_dot_ou
          char = nil
        when 'a'..'z', 'A'..'Z', '0'..'9'
          tokens << ID.new("System")
          tokens << Delimiter.new('.')
          input = 'o' + char
          state = :id
          char = nil
        else
          tokens << ID.new("System")
          tokens << Delimiter.new('.')
          tokens << ID.new('o')
          input = ''
          state = :start
        end
      when :token_System_dot_ou
        case char
        when 't'
          state = :token_System_dot_out
          char = nil
        when 'a'..'z', 'A'..'Z', '0'..'9'
          tokens << ID.new("System")
          tokens << Delimiter.new('.')
          input = 'ou' + char
          state = :id
          char = nil
        else
          tokens << ID.new("System")
          tokens << Delimiter.new('.')
          tokens << ID.new('ou')
          input = ''
          state = :start
        end
      when :token_System_dot_out
        case char
        when '.'
          state = :token_System_dot_out_dot
          char = nil
        when 'a'..'z', 'A'..'Z', '0'..'9'
          tokens << ID.new("System")
          tokens << Delimiter.new('.')
          input = 'out' + char
          state = :id
          char = nil
        else
          tokens << ID.new("System")
          tokens << Delimiter.new('.')
          tokens << ID.new('out')
          input = ''
          state = :start
        end
      when :token_System_dot_out_dot
        case char
        when 'p'
          state = :token_System_dot_out_dot_p
          char = nil
        when 'a'..'z', 'A'..'Z', '0'..'9'
          tokens << ID.new("System")
          tokens << Delimiter.new('.')
          tokens << ID.new("out")
          tokens << Delimiter.new('.')
          input = char
          state = :id
          char = nil
        else
          tokens << ID.new("System")
          tokens << Delimiter.new('.')
          tokens << ID.new('out')
          tokens << Delimiter.new('.')
          input = ''
          state = :start
        end
      when :token_System_dot_out_dot_p
        case char
        when 'r'
          state = :token_System_dot_out_dot_pr
          char = nil
        when 'a'..'z', 'A'..'Z', '0'..'9'
          tokens << ID.new("System")
          tokens << Delimiter.new('.')
          tokens << ID.new("out")
          tokens << Delimiter.new('.')
          input = 'p' + char
          state = :id
          char = nil
        else
          tokens << ID.new("System")
          tokens << Delimiter.new('.')
          tokens << ID.new('out')
          tokens << Delimiter.new('.')
          tokens << ID.new('p')
          input = ''
          state = :start
        end
      when :token_System_dot_out_dot_pr
        case char
        when 'i'
          state = :token_System_dot_out_dot_pri
          char = nil
        when 'a'..'z', 'A'..'Z', '0'..'9'
          tokens << ID.new("System")
          tokens << Delimiter.new('.')
          tokens << ID.new("out")
          tokens << Delimiter.new('.')
          input = 'pr' + char
          state = :id
          char = nil
        else
          tokens << ID.new("System")
          tokens << Delimiter.new('.')
          tokens << ID.new('out')
          tokens << Delimiter.new('.')
          tokens << ID.new('pr')
          input = ''
          state = :start
        end
      when :token_System_dot_out_dot_pri
        case char
        when 'n'
          state = :token_System_dot_out_dot_prin
          char = nil
        when 'a'..'z', 'A'..'Z', '0'..'9'
          tokens << ID.new("System")
          tokens << Delimiter.new('.')
          tokens << ID.new("out")
          tokens << Delimiter.new('.')
          input = 'pri' + char
          state = :id
          char = nil
        else
          tokens << ID.new("System")
          tokens << Delimiter.new('.')
          tokens << ID.new('out')
          tokens << Delimiter.new('.')
          tokens << ID.new('pri')
          input = ''
          state = :start
        end
      when :token_System_dot_out_dot_prin
        case char
        when 't'
          state = :token_System_dot_out_dot_print
          char = nil
        when 'a'..'z', 'A'..'Z', '0'..'9'
          tokens << ID.new("System")
          tokens << Delimiter.new('.')
          tokens << ID.new("out")
          tokens << Delimiter.new('.')
          input = 'prin' + char
          state = :id
          char = nil
        else
          tokens << ID.new("System")
          tokens << Delimiter.new('.')
          tokens << ID.new('out')
          tokens << Delimiter.new('.')
          tokens << ID.new('prin')
          input = ''
          state = :start
        end
      when :token_System_dot_out_dot_print
        case char
        when 'l'
          state = :token_System_dot_out_dot_printl
          char = nil
        when 'a'..'z', 'A'..'Z', '0'..'9'
          tokens << ID.new("System")
          tokens << Delimiter.new('.')
          tokens << ID.new("out")
          tokens << Delimiter.new('.')
          input = 'print' + char
          state = :id
          char = nil
        else
          tokens << ID.new("System")
          tokens << Delimiter.new('.')
          tokens << ID.new('out')
          tokens << Delimiter.new('.')
          tokens << ID.new('print')
          input = ''
          state = :start
        end
      when :token_System_dot_out_dot_printl
        case char
        when 'n'
          state = :token_System_dot_out_dot_println
          char = nil
        when 'a'..'z', 'A'..'Z', '0'..'9'
          tokens << ID.new("System")
          tokens << Delimiter.new('.')
          tokens << ID.new("out")
          tokens << Delimiter.new('.')
          input = 'printl' + char
          state = :id
          char = nil
        else
          tokens << ID.new("System")
          tokens << Delimiter.new('.')
          tokens << ID.new('out')
          tokens << Delimiter.new('.')
          tokens << ID.new('printl')
          input = ''
          state = :start
        end
      when :token_System_dot_out_dot_println
        case char
        when 'a'..'z', 'A'..'Z', '0'..'9'
          tokens << ID.new("System")
          tokens << Delimiter.new('.')
          tokens << ID.new("out")
          tokens << Delimiter.new('.')
          input = 'println'
          state = :id
        else
          tokens << ReservedWord.new('System.out.println')
          input = ''
          state = :start
        end
      when :reserved_word
        case char
        when /^[a-zA-Z0-9]$/
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
        when 'a'..'z', 'A'..'Z', '0'..'9'
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
          char = file.readchar until char =~ /[\n\r]/ or file.eof?
          lineno += 1
          state = :start
          char = nil
        when "*"
          #====================================================================
          # This is the opening of a block comment
          #====================================================================
          input = ""
          state = :block_comment
          char = nil
        else
          #====================================================================
          # We found a / operator. Back to normal business.
          #====================================================================
          tokens << Operator.new('/')
          input = ''
          state = :start
          # char is still unused; keep for later
        end
      when :block_comment
        #======================================================================
        # Inside a block comment
        #======================================================================
        case char
        when "*"
          #====================================================================
          # Could be the end of a block comment
          #====================================================================
          input = ""
          state = :block_comment_star
        when "\n", "\r"
          lineno += 1
        end
        char = nil
      when :block_comment_star
        input = ''
        case char
        when "/"
          # done with comment!
          state = :start
        when "*"
          # stay in this state
        else
          # back to regular block comment
          state = :block_comment
        end
        char = nil
      else
        raise [state.to_s, input, char].to_s
      end
    end until is_done
    @file.close
    @errors = errors
    @tokens = tokens
    self
  end

  def print
    run
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
