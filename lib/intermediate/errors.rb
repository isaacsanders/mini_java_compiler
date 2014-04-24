module Intermediate
  class DefineSuperclassFirstError
    def initialize(klass_id)
      @klass_id = klass_id
    end
  end

  class DuplicateFieldError
    def initialize(klass_id, id)
      @klass_id, @id = klass_id, id
    end
  end

  class ShadowingClassVariableError
    def initialize(klass_id, id)
      @klass_id, @id = klass_id, id
    end
  end

  class TypeMismatchError
    attr_reader :id, :expected, :actual

    def initialize(id, expected, actual)
      @id = id.input_text
      @expected = expected.type
      @actual = actual.type
    end

    def message
      "TypeMismatchError: #{id} should be #{expected}, but was #{actual}"
    end
  end

  class UninitializedConstantError
    def initialize(klass_id)
      @klass_id = klass_id
    end
  end

  class UnexpectedTypeError
    attr_reader :expr, :expected_type

    def initialize(expr, expected_type)
      @expr = expr
      @expected_type = expected_type
    end

    def message
      "UnexpectedTypeError: #{expr.to_code} should be #{expected_type.type}"
    end
  end
end
