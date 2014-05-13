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
    attr_reader :name, :actual, :declared

    def initialize name, actual, declared
      @name = name.to_code
      @actual = actual.to_code
      @declared = declared.to_code
    end

    def message
      "MethodReturnTypeMismatchError: Actual return type #{actual} of method #{name} does not match declared type #{declared}"
    end
  end

  class ArgumentMismatchError
    attr_reader :actual, :declared

    def initialize actual, declared
      @actual = actual.to_code
      @declared = declared.to_code
    end

    def message
      "ArgumentMismatchError: Argument type #{actual} is incompatible with formal parameter type #{declared}"
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
      "InvalidAssignmentError: Cannot assign type #{actual} to variable #{name} of type #{declared}"
    end
  end

  class NoClassError < ErrorBase
    def message
      "NoClassError: Cannot find class named #{name}"
    end
  end

  class InvalidInstantiationError < ErrorBase
    def message
      "InvalidInstantiationError: Cannot instantiate undeclared class named #{name}"
    end
  end

  class OverloadedMethodError < ErrorBase
    def message
      "OverloadedMethodError: Cannot overload methods. Method #{name} has different type signature than inherited method of the same name."
    end
  end

  class MethodRedeclarationError < ErrorBase
    def message
      "MethodRedeclarationError: Cannot redeclare method #{name}"
    end
  end

  class ClassRedeclarationError < ErrorBase
    def message
      "ClassRedeclarationError: Class named #{name} already exists."
    end
  end

  class NonbooleanIfConditionError < ErrorBase
    alias type name

    def message
      "NonbooleanIfConditionError: Condition for if statement is of type #{type} instead of boolean"
    end
  end

  class DuplicateFormalError < ErrorBase
    def message
      "DuplicateFormalError: Formal parameter named #{name} duplicates the name of another formal parameter."
    end
  end

  class InvalidPrintlnError < ErrorBase
    alias type name

    def message
      "InvalidPrintlnError: In MiniJava, System.out.println only takes an int. The expression has type #{type}"
    end
  end

  class NoMethodError
    attr_reader :name, :type

    def initialize(name, type)
      @name = name.to_code
      @type = type.to_code
    end

    def message
      "NoMethodError: No method named #{name} found for class #{type}"
    end
  end

  class UndeclaredVariableError < ErrorBase
    def message
      "UndeclaredVariableError: No variable named #{name} exists in the current scope."
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
      "InvalidLeftArgument: Left argument of type #{actual} does not match expected type #{expected} for operator #{operator}"
    end
  end

  class InvalidUnaryArgument < OperatorErrorBase
    def message
      "InvalidUnaryArgument: Operand type #{actual} is not compatible with expected type #{expected} of operator #{operator}"
    end
  end

  class InvalidRightArgument < OperatorErrorBase
    def message
      "InvalidRightArgument: Right argument of type #{actual} does not match expected type #{expected} for operator #{operator}"
    end
  end

  class UndefinedSuperclassError < ErrorBase
    def message
      "UndefinedSuperclassError: Superclass name #{name} not in scope."
    end
  end

  class ShadowingClassVariableError < ErrorBase
    def message
      "ShadowingClassVariableError: The class variable #{name} is already declared.  Redeclaration and shadowing are not allowed."
    end
  end

  class InvalidEqualityComparisonArgumentsError
    attr_reader :lhs, :rhs

    def initialize(lhs, rhs)
      @lhs, @rhs = lhs.to_code, rhs.to_code
    end

    def message
      "InvalidEqualityComparisonArgumentsError: The operand types, #{lhs} and #{rhs}, are not compatible for equality comparison"
    end
  end

  class LocalVariableRedeclarationError < ErrorBase
    def message
      "LocalVariableRedeclarationError: The variable #{name} is already declared in the current scope."
    end
  end

  class UndeclaredVariableError < ErrorBase
    def message
      "UndeclaredVariableError: Variable #{name} is not declared."
    end
  end

  class NonbooleanWhileConditionError < ErrorBase
    alias type name

    def message
      "NonbooleanWhileConditionError: While loop condition must be a boolean.  The expressions has type #{type}"
    end
  end
end
