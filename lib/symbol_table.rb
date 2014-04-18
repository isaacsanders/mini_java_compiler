class SymbolTable
  def initialize(parent)
    @parent = parent
    @table = {}
  end
  
  def add_symbol(type, id)
    if self.get_symbol(id) # todo: fix cases where shadowing is ok
      return :preexists
    else
      @table[id] = Symbol.new(type, id)
      return nil
    end
  end

  def get_symbol(id)
    @table[id] or get_symbol_from_parent(id)
  end

  def get_symbol_from_parent(id)
    return nil if parent.nil?
    parent.get(id)
  end
  
  # todo check type of types
end

class Symbol
  def initialize(type, id)
    @type, @id = type, id
  end
end