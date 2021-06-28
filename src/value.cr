require "uuid"
require "./exceptions"

module FayrantLang
  enum ValueType
    Null
    Boolean
    Number
    String
    Object
    Function
  end

  abstract class AnyValue
    getter type

    def initialize(@type : ValueType)
    end

    abstract def to_string

    def get_boolean : Bool
      raise ValueError.new ValueType::Boolean, @type
    end

    def get_number : Float64
      raise ValueError.new ValueType::Number, @type
    end

    def get_string : String
      raise ValueError.new ValueType::String, @type
    end

    def get_object : ObjectValue
      raise ValueError.new ValueType::Object, @type
    end

    def get_function : FunctionValue
      raise ValueError.new ValueType::Function, @type
    end

    def ==(other)
      false
    end
  end

  class NullValue < AnyValue
    def initialize
      super ValueType::Null
    end

    def to_string
      "null"
    end

    def ==(other : NullValue)
      true
    end
  end

  class BooleanValue < AnyValue
    getter value

    def initialize(@value : Bool)
      super ValueType::Boolean
    end

    def to_string
      @value.to_s
    end

    def get_boolean
      @value
    end

    def ==(other : BooleanValue)
      @value == other.value
    end
  end

  class NumberValue < AnyValue
    getter value

    def initialize(@value : Float64)
      super ValueType::Number
    end

    def to_string
      @value.to_s
    end

    def get_number
      @value
    end

    def ==(other : NumberValue)
      @value == other.value
    end
  end

  class StringValue < AnyValue
    getter value

    def initialize(@value : String)
      super ValueType::String
    end

    def to_string
      @value
    end

    def get_string
      @value
    end

    def ==(other : StringValue)
      @value == other.value
    end
  end

  class ObjectValue < AnyValue
    getter fields
    getter uuid

    def initialize(
      @className : String,
      @methods : Hash(String, FunctionDeclarationStatement),
      @methods_ctx : Context
    )
      super ValueType::Object
      @fields = Hash(String, AnyValue).new
      @uuid = UUID.random
    end

    def get_field(name : String)
      if fields.has_key?(name)
        fields[name]
      elsif @methods.has_key?(name)
        method = @methods[name]
        obj_fn = BuiltinFunction.new method.params.size do |args|
          obj_ctx = Context.new @methods_ctx
          fn = UserFunction.new method.params, method.body, obj_ctx
          fn.call(args)
        end
        obj_fn
      else
        NullValue.new
      end
    end

    def set_field(name : String, value : AnyValue)
      fields[name] = value
    end

    def to_string
      "[object #{@className}]"
    end

    def get_object
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
      super ValueType::Function
      @uuid = UUID.random
    end

    def get_function
      self
    end

    def to_string
      "[Function]"
    end

    def ==(other : FunctionValue)
      uuid == other.uuid
    end

    abstract def call(args : Array(AnyValue)) : AnyValue
  end

  class UserFunction < FunctionValue
    def initialize(@params : Array(String), @body : Array(Statement), @ctx : Context)
      super params.size
    end

    def call(args : Array(AnyValue)) : AnyValue
      fn_ctx = Context.new @ctx
      @params.zip(args) do |param, value|
        fn_ctx.create_var(param, value)
      end
      res = exec_body @body, fn_ctx
      case res[0]
      when ExecResult::NONE
        NullValue.new
      when ExecResult::RETURN
        res[1]
      when ExecResult::BREAK
        raise Exception.new "TODO - break is invalid outside of loop"
      when ExecResult::CONTINUE
        raise Exception.new "TODO - continue is invalid outside of loop"
      else
        raise Exception.new "UNREACHABLE CODE"
      end
    end
  end

  # class UserMethod < FunctionValue
  #   def initialize(@this : ObjectValue, @params : Array(String), @body : Array(Object), @ctx : Context) # TODO
  #     super params.size
  #   end

  #   def call(args : Array(AnyValue)) : AnyValue
  #     NullValue.new # TODO
  #   end
  # end

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
