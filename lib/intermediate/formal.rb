require_relative 'errors'

module Intermediate
  class Formal
    attr_reader :name, :type

    def initialize(type, name)
      @type, @name = type, name
    end
  end
end
