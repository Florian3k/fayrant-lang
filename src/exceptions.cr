require "./value.cr"

module FayrantLang
  class SyntaxError < Exception
    def initialize(reason : String)
      super reason
    end
  end

  abstract class ExecutionError < Exception
    def initialize(reason : String)
      super reason
    end
  end

  class ArityMismatchError < ExecutionError
    def initialize(@expected : Int32, @actual : Int32)
      super "ArityMismatchError: expected #{@expected} arguments, instead got #{@actual}"
    end
  end

  class TypeError < ExecutionError
    def initialize(@expected : ValueType, @actual : ValueType)
      super "TypeError: expected type #{@expected}, instead got #{@actual}"
    end

    def initialize(@expected : String, @actual : String)
      super "TypeError: expected type #{@expected}, instead got #{@actual}"
    end
  end

  class UndefinedVarError < ExecutionError
    def initialize(@name : String)
      super "UndefinedVarError: variable #{@name} is not defined"
    end
  end

  class DefinedVarError < ExecutionError
    def initialize(@name : String)
      super "DefinedVarError: variable #{@name} is already defined"
    end
  end

  class ArithmeticError < ExecutionError
    def initialize(reason : String)
      super "ArithmeticError: #{reason}"
    end
  end

  class StatementError < ExecutionError
    def initialize(reason : String)
      super "StatementError: #{reason}"
    end
  end
end
