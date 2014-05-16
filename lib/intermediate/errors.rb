module Intermediate
  class NameErrorBase
    attr_reader :name

    def initialize(name)
      @name = name
    end

    def message
      raise NotImplementedError.new("Subclass this class and implement `message`")
    end
  end

  class TypeErrorBase
    attr_reader :type

    def initialize(type)
      @type = type.input_text
    end

    def message
      raise NotImplementedError.new("Subclass this class and implement `message`")
    end
  end

  class MethodReturnTypeMismatchError
    attr_reader :name, :declared, :actual

    def initialize name, declared, actual
      @name = name
      @declared = declared.input_text
      @actual = actual.input_text
    end

    def message
      "Actual return type #{actual} of method #{name} does not match declared type #{declared}"
    end
  end

  class ArgumentMismatchError
    attr_reader :actual, :declared

    def initialize actual, declared
      @actual = actual.input_text
      @declared = declared.input_text
    end

    def message
      "Argument type #{actual} is incompatible with formal parameter type #{declared}"
    end
  end

  class InvalidAssignmentError
    attr_reader :name, :actual, :declared

    def initialize name, actual, declared
      @name = name
      @actual = actual.input_text
      @declared = declared.input_text
    end

    def message
      "Cannot assign type #{actual} to variable #{name} of type #{declared}"
    end
  end

  class NoClassError < NameErrorBase
    def message
      "Cannot find class named #{name}"
    end
  end

  class InvalidInstantiationError < NameErrorBase
    def message
      "Cannot instantiate undeclared class named #{name}"
    end
  end

  class OverloadedMethodError < NameErrorBase
    def message
      "Cannot overload methods.  Method #{name} has different type signature than inherited method of the same name."
    end
  end

  class MethodRedeclarationError < NameErrorBase
    def message
      "Cannot redeclare method #{name}"
    end
  end

  class ClassRedeclarationError < NameErrorBase
    def message
      "Class named #{name} already exists."
    end
  end

  class NonbooleanIfConditionError < TypeErrorBase
    def message
      "Condition for if statement is of type #{type} instead of boolean"
    end
  end

  class DuplicateFormalError < NameErrorBase
    def message
      "Formal parameter named #{name} duplicates the name of another formal parameter."
    end
  end

  class InvalidPrintlnError < TypeErrorBase
    def message
      "In MiniJava, System.out.println only takes an int. The expression has type #{type}"
    end
  end

  class NoMethodError
    attr_reader :name, :type

    def initialize(name, type)
      @name = name
      @type = type.input_text
    end

    def message
      "No method named #{name} found for class #{type}"
    end
  end

  class UndeclaredVariableError < NameErrorBase
    def message
      "No variable named #{name} exists in the current scope."
    end
  end

  class OperatorErrorBase
    attr_reader :actual, :expected, :operator

    def initialize(actual, expected, operator)
      @actual = actual.input_text
      @expected = expected.input_text
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

  class UndefinedSuperclassError < NameErrorBase
    def message
      "Superclass name #{name} not in scope."
    end
  end

  class ShadowingClassVariableError < NameErrorBase
    def message
      "The class variable #{name} is already declared.  Redeclaration and shadowing are not allowed."
    end
  end

  class InvalidEqualityComparisonArgumentsError
    attr_reader :lhs, :rhs

    def initialize(lhs, rhs)
      @lhs, @rhs = lhs.input_text, rhs.input_text
    end

    def message
      "The operand types, #{lhs} and #{rhs}, are not compatible for equality comparison"
    end
  end

  class LocalVariableRedeclarationError < NameErrorBase
    def message
      "The variable #{name} is already declared in the current scope."
    end
  end

  class UndeclaredVariableError < NameErrorBase
    def message
      "Variable #{name} is not declared."
    end
  end

  class NonbooleanWhileConditionError < TypeErrorBase
    def message
      "While loop condition must be a boolean.  The expressions has type #{type}"
    end
  end
end
