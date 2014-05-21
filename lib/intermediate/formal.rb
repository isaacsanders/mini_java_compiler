require_relative 'errors'

module Intermediate
  class Formal
    attr_reader :id, :type

    def initialize(type, id)
      @type, @id = type, id
    end

    def name
      id.input_text
    end
  end
end
