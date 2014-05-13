module Intermediate
  class ErrorBase
    attr_reader :name

    def initialize(name)
      @name = name.to_code
    end

    def message
      raise NotImplementedError.new("Subclass this class and implement `message`")
    end
  end

  class MethodReturnTypeMismatchError
    attr_reader :name, :declared, :actual

    def initialize name, declared, actual
      @name = name.to_code
      @declared = declared.to_code
      @actual = actual.to_code
    end

    def message
      "Actual return type #{actual} of method #{name} does not match declared type #{declared}"
    end
  end

  class ArgumentMismatchError
    attr_reader :actual, :declared

    def initialize actual, declared
      @actual = actual.to_code
      @declared = declared.to_code
    end

    def message
      "Argument type #{actual} is incompatible with formal parameter type #{declared}"
    end
  end

  class InvalidAssignmentError
    attr_reader :name, :actual, :declared

    def initialize name, actual, declared
      @name = name.to_code
      @actual = actual.to_code
      @declared = declared.to_code
    end

    def message
      "Cannot assign type #{actual} to variable #{name} of type #{declared}"
    end
  end

  class NoClassError < ErrorBase
    def message
      "Cannot find class named #{name}"
    end
  end

  class InvalidInstantiationError < ErrorBase
    def message
      "Cannot instantiate undeclared class named #{name}"
    end
  end

  class OverloadedMethodError < ErrorBase
    def message
      "Cannot overload methods. Method #{name} has different type signature than inherited method of the same name."
    end
  end

  class MethodRedeclarationError < ErrorBase
    def message
      "Cannot redeclare method #{name}"
    end
  end

  class ClassRedeclarationError < ErrorBase
    def message
      "Class named #{name} already exists."
    end
  end

  class NonbooleanIfConditionError < ErrorBase
    alias type name

    def message
      "Condition for if statement is of type #{type} instead of boolean"
    end
  end

  class DuplicateFormalError < ErrorBase
    def message
      "Formal parameter named #{name} duplicates the name of another formal parameter."
    end
  end

  class InvalidPrintlnError < ErrorBase
    alias type name

    def message
      "In MiniJava, System.out.println only takes an int. The expression has type #{type}"
    end
  end

  class NoMethodError
    attr_reader :name, :type

    def initialize(name, type)
      @name = name.to_code
      @type = type.to_code
    end

    def message
      "No method named #{name} found for class #{type}"
    end
  end

  class UndeclaredVariableError < ErrorBase
    def message
      "No variable named #{name} exists in the current scope."
    end
  end

  class OperatorErrorBase
    attr_reader :actual, :expected, :operator

    def initialize(actual, expected, operator)
      @actual = actual.to_code
      @expected = expected.to_code
      @operator = operator
    end
  end

  class InvalidLeftArgument < OperatorErrorBase
    def message
      "Left argument of type #{actual} does not match expected type #{expected} for operator #{operator}"
    end
  end

  class InvalidUnaryArgument < OperatorErrorBase
    def message
      "Operand type #{actual} is not compatible with expected type #{expected} of operator #{operator}"
    end
  end

  class InvalidRightArgument < OperatorErrorBase
    def message
      "Right argument of type #{actual} does not match expected type #{expected} for operator #{operator}"
    end
  end

  class UndefinedSuperclassError < ErrorBase
    def message
      "Superclass name #{name} not in scope."
    end
  end

  class ShadowingClassVariableError < ErrorBase
    def message
      "The class variable #{name} is already declared.  Redeclaration and shadowing are not allowed."
    end
  end

  class InvalidEqualityComparisonArgumentsError
    attr_reader :lhs, :rhs

    def initialize(lhs, rhs)
      @lhs, @rhs = lhs.to_code, rhs.to_code
    end

    def message
      "The operand types, #{lhs} and #{rhs}, are not compatible for equality comparison"
    end
  end

  class LocalVariableRedeclarationError < ErrorBase
    def message
      "The variable #{name} is already declared in the current scope."
    end
  end

  class UndeclaredVariableError < ErrorBase
    def message
      "Variable #{name} is not declared."
    end
  end

  class NonbooleanWhileConditionError < ErrorBase
    alias type name

    def message
      "While loop condition must be a boolean.  The expressions has type #{type}"
    end
  end
end
