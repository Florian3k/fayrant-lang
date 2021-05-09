require "uuid"
require "./exceptions"

module FayrantLang
  module Interpreter
    include Exceptions

    module Values
      abstract class AnyValue
        getter type

        def initialize(@type : String)
        end

        abstract def toString

        def getBoolean : Bool
          raise ValueError.new "Boolean", @type
        end

        def getNumber : Float64
          raise ValueError.new "Number", @type
        end

        def getString : String
          raise ValueError.new "String", @type
        end

        def getObject : ObjectValue
          raise ValueError.new "Object", @type
        end

        def getFunction : FunctionValue
          raise ValueError.new "Function", @type
        end

        def ==(other)
          false
        end
      end

      class VoidValue < AnyValue
        def initialize
          super "Void"
        end

        def toString
          "void"
        end

        def ==(other : VoidValue)
          true
        end
      end

      class BooleanValue < AnyValue
        getter value

        def initialize(@value : Bool)
          super "Boolean"
        end

        def toString
          @value.to_s
        end

        def getBoolean
          @value
        end

        def ==(other : BooleanValue)
          @value == other.value
        end
      end

      class NumberValue < AnyValue
        getter value

        def initialize(@value : Float64)
          super "Number"
        end

        def toString
          @value.to_s
        end

        def getNumber
          @value
        end

        def ==(other : NumberValue)
          @value == other.value
        end
      end

      class StringValue < AnyValue
        getter value

        def initialize(@value : String)
          super "String"
        end

        def toString
          @value
        end

        def getString
          @value
        end

        def ==(other : StringValue)
          @value == other.value
        end
      end

      class ObjectValue < AnyValue
        getter fields
        getter uuid

        def initialize(@classType : String)
          super "Object"
          @fields = Hash(String, AnyValue).new
          @uuid = UUID.random
        end

        def toString
          "[object #{@classType}]"
        end

        def getObject
          self
        end

        def ==(other : ObjectValue)
          uuid == other.uuid
        end
      end

      abstract class FunctionValue < AnyValue
        getter arity
        getter uuid

        def initialize(@arity : Int32)
          super "Function"
          @uuid = UUID.random
        end

        def getFunction
          self
        end

        def toString
          "[Function]"
        end

        def ==(other : FunctionValue)
          uuid == other.uuid
        end

        abstract def call(args : Array(AnyValue)) : AnyValue
      end

      class UserFunction < FunctionValue
        def initialize(@params : Array(String), @body : Array(Object)) # TODO
          super params.length
        end

        def call(args : Array(AnyValue)) : AnyValue
          VoidValue.new # TODO
        end
      end

      class UserMethod < FunctionValue
        def initialize(@this : ObjectValue, @params : Array(String), @body : Array(Object)) # TODO
          super params.length
        end

        def call(args : Array(AnyValue)) : AnyValue
          VoidValue.new # TODO
        end
      end

      class BuiltinFunction < FunctionValue
        def initialize(arity : Int32, &body : Array(AnyValue) -> AnyValue)
          super arity
          @body = body
        end

        def call(args : Array(AnyValue)) : AnyValue
          if @arity != -1 && @arity != args.size
            raise ArityMismatchError.new @arity, args.size
          end
          @body.call(args)
        end
      end
    end
  end
end
