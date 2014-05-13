module Intermediate
  class Field
    attr_reader :id, :type

    def initialize(type, id)
      @type, @id = type, id
    end

    def to_code
      id.to_code
    end

    def init_st(parent)
      parent.add_symbol(@type, @id)
    end
  end
end
