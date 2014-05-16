class SymbolTable
  PREEXISTS = :preexists
  attr_reader :parent

  def initialize(parent)
    @parent = parent
    @table = {}
    @errors = []
  end

  def add_symbol(type, id)
    if self.get_symbol(id) # todo: fix cases where shadowing is ok
      return ::SymbolTable::PREEXISTS
    else
      @table[id] = Symbol.new(type, id)
      return nil
    end
  end

  def get_symbol(id)
    @table[id] or get_symbol_from_parent(id)
  end

  def add_error(error)
    if parent
      parent.add_error(error)
    else
      @errors << error
    end
  end

  def add_class(type, id)
    add_symbol(type, [:class, id])
  end

  def get_class(id)
    get_symbol([:class, id])
  end

  def add_field(type, id)
    add_symbol(type, [:field, id])
  end

  def get_field(id)
    get_symbol([:field, id])
  end

  def get_symbol_from_parent(id)
    return nil if parent.nil?
    parent.get_symbol(id)
  end

  # todo check type of types
  class Symbol
    attr_reader :type, :id

    def initialize(type, id)
      @type, @id = type, id
    end

    def input_text
      id.input_text
    end
  end
end

