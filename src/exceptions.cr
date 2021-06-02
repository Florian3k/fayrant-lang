require "./value.cr"

module FayrantLang
  class ValueError < Exception
    def initialize(@expected : ValueType, @actual : ValueType)
      super "ValueError: expected type #{@expected}, instead got #{@actual}"
    end
    def initialize(@expected : String, @actual : String)
      super "ValueError: expected type #{@expected}, instead got #{@actual}"
    end
    
  end
  

  class ArityMismatchError < Exception
    def initialize(@expected : Int32, @actual : Int32)
      super "ArityMismatchError: expected #{@expected} arguments, instead got #{@actual}"
    end
  end
end
