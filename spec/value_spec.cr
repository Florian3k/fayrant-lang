require "spec"
require "../src/value.cr"

include FayrantLang

describe "FayrantLang Values" do
  describe "NullValue" do
    it ".get* should throw ValueError" do
      expect_raises(ValueError, "ValueError: expected type Boolean, instead got Null") do
        NullValue.new.getBoolean
      end

      expect_raises(ValueError, "ValueError: expected type Number, instead got Null") do
        NullValue.new.getNumber
      end

      expect_raises(ValueError, "ValueError: expected type String, instead got Null") do
        NullValue.new.getString
      end

      expect_raises(ValueError, "ValueError: expected type Object, instead got Null") do
        NullValue.new.getObject
      end

      expect_raises(ValueError, "ValueError: expected type Function, instead got Null") do
        NullValue.new.getFunction
      end
    end
  end

  describe "BooleanValue" do
    it ".getBoolean should return given boolean" do
      bool = BooleanValue.new true
      bool.getBoolean.should eq true

      bool2 = BooleanValue.new false
      bool2.getBoolean.should eq false
    end

    it ".type should return Boolean type" do
      bool = BooleanValue.new true
      bool.type.should eq "Boolean"
    end

    it ".getNumber should throw ValueError" do
      expect_raises(ValueError, "ValueError: expected type Number, instead got Boolean") do
        bool = BooleanValue.new true
        bool.getNumber
      end
    end
  end

  describe "NumberValue" do
    it ".getNumber should return given number" do
      num = NumberValue.new 7
      num.getNumber.should eq 7
    end

    it ".type should return Number type" do
      num = NumberValue.new 7
      num.type.should eq "Number"
    end
  end

  describe "StringValue" do
    it ".getString should return given string" do
      str = StringValue.new "testing"
      str.getString.should eq "testing"
    end

    it ".type should return String type" do
      str = StringValue.new "testing"
      str.type.should eq "String"
    end
  end

  describe "ObjectValue" do
    it ".getObject should return the object itself" do
      obj = ObjectValue.new "SomeClass"
      (obj.getObject == obj).should eq true
    end

    it ".type should return Object type" do
      obj = ObjectValue.new "SomeClass"
      obj.type.should eq "Object"
    end

    it "Object should be equal only to itself" do
      obj1 = ObjectValue.new "SomeClass"
      obj2 = ObjectValue.new "SomeClass"
      (obj1 == obj1).should eq true
      (obj2 == obj2).should eq true
      (obj1 == obj2).should eq false
    end
  end

  describe "BuiltinFunction" do
    it ".getFunction should return the function itself" do
      fn = BuiltinFunction.new 0 do |args|
        NullValue.new
      end
      (fn.getFunction == fn).should eq true
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
        NumberValue.new(args[0].getNumber + 7)
      end
      ret = fn.call([NumberValue.new 6] of AnyValue)
      (ret == NumberValue.new 13).should eq true
      (ret == NumberValue.new 14).should eq false
    end

    it ".call should throw on arity mismatch" do
      fn = BuiltinFunction.new 1 do |args|
        NumberValue.new(args[0].getNumber + 7)
      end
      expect_raises(ArityMismatchError, "ArityMismatchError: expected 1 arguments, instead got 0") do
        ret = fn.call([] of AnyValue)
      end
    end
  end
end
