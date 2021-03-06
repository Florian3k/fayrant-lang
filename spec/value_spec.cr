require "spec"
require "../src/value.cr"

include FayrantLang

describe "FayrantLang Values" do
  describe "NullValue" do
    it ".get* should throw TypeError" do
      expect_raises(TypeError, "TypeError: expected type Boolean, instead got Null") do
        NullValue.new.get_boolean
      end

      expect_raises(TypeError, "TypeError: expected type Number, instead got Null") do
        NullValue.new.get_number
      end

      expect_raises(TypeError, "TypeError: expected type String, instead got Null") do
        NullValue.new.get_string
      end

      expect_raises(TypeError, "TypeError: expected type Object, instead got Null") do
        NullValue.new.get_object
      end

      expect_raises(TypeError, "TypeError: expected type Function, instead got Null") do
        NullValue.new.get_function
      end
    end
  end

  describe "BooleanValue" do
    it ".get_boolean should return given boolean" do
      bool = BooleanValue.new true
      bool.get_boolean.should eq true

      bool2 = BooleanValue.new false
      bool2.get_boolean.should eq false
    end

    it ".type should return Boolean type" do
      bool = BooleanValue.new true
      bool.type.should eq ValueType::Boolean
    end

    it ".get_number should throw TypeError" do
      expect_raises(TypeError, "TypeError: expected type Number, instead got Boolean") do
        bool = BooleanValue.new true
        bool.get_number
      end
    end
  end

  describe "NumberValue" do
    it ".get_number should return given number" do
      num = NumberValue.new 7
      num.get_number.should eq 7
    end

    it ".type should return Number type" do
      num = NumberValue.new 7
      num.type.should eq ValueType::Number
    end
  end

  describe "StringValue" do
    it ".get_string should return given string" do
      str = StringValue.new "testing"
      str.get_string.should eq "testing"
    end

    it ".type should return String type" do
      str = StringValue.new "testing"
      str.type.should eq ValueType::String
    end
  end

  describe "ObjectValue" do
    empty_methods = Hash(String, FunctionDeclarationStatement).new
    empty_ctx = Context.new
    it ".get_object should return the object itself" do
      obj = ObjectValue.new "SomeClass", empty_methods, empty_ctx
      (obj.get_object == obj).should eq true
    end

    it ".type should return Object type" do
      obj = ObjectValue.new "SomeClass", empty_methods, empty_ctx
      obj.type.should eq ValueType::Object
    end

    it "Object should be equal only to itself" do
      obj1 = ObjectValue.new "SomeClass", empty_methods, empty_ctx
      obj2 = ObjectValue.new "SomeClass", empty_methods, empty_ctx
      (obj1 == obj1).should eq true
      (obj2 == obj2).should eq true
      (obj1 == obj2).should eq false
    end
  end

  describe "BuiltinFunction" do
    it ".get_function should return the function itself" do
      fn = BuiltinFunction.new 0 do |args|
        NullValue.new
      end
      (fn.get_function == fn).should eq true
    end

    it "Function should be equal only to itself" do
      fn1 = BuiltinFunction.new 0 do |args|
        NullValue.new
      end
      fn2 = BuiltinFunction.new 0 do |args|
        NullValue.new
      end
      (fn1 == fn1).should eq true
      (fn2 == fn2).should eq true
      (fn1 == fn2).should eq false
    end

    it ".call should return correct value" do
      fn = BuiltinFunction.new 1 do |args|
        NumberValue.new(args[0].get_number + 7)
      end
      ret = fn.call([NumberValue.new 6] of AnyValue)
      (ret == NumberValue.new 13).should eq true
      (ret == NumberValue.new 14).should eq false
    end

    it ".call should throw on arity mismatch" do
      fn = BuiltinFunction.new 1 do |args|
        NumberValue.new(args[0].get_number + 7)
      end
      expect_raises(ArityMismatchError, "ArityMismatchError: expected 1 arguments, instead got 0") do
        ret = fn.call([] of AnyValue)
      end
    end
  end
end
