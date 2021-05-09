require "spec"
require "../../src/interpreter/value.cr"

include FayrantLang::Interpreter::Values
include FayrantLang::Interpreter::Exceptions

describe FayrantLang::Interpreter::Values do
  describe "VoidValue" do
    it ".get* should throw ValueError" do
      expect_raises(ValueError, "ValueError: expected type Boolean, instead got Void") do
        VoidValue.new.getBoolean
      end

      expect_raises(ValueError, "ValueError: expected type Number, instead got Void") do
        VoidValue.new.getNumber
      end

      expect_raises(ValueError, "ValueError: expected type String, instead got Void") do
        VoidValue.new.getString
      end

      expect_raises(ValueError, "ValueError: expected type Object, instead got Void") do
        VoidValue.new.getObject
      end

      expect_raises(ValueError, "ValueError: expected type Function, instead got Void") do
        VoidValue.new.getFunction
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

  describe "BuiltinFunction" do
    it ".call should return correct value" do
      fn = BuiltinFunction.new 1 do |args| NumberValue.new(args[0].getNumber + 7) end
      ret = fn.call([NumberValue.new 6] of AnyValue)
      (ret == NumberValue.new 13).should eq true
      (ret == NumberValue.new 14).should eq false
    end

    it ".call should throw on arity mismatch" do
      fn = BuiltinFunction.new 1 do |args| NumberValue.new(args[0].getNumber + 7) end
      expect_raises(ArityMismatchError, "ArityMismatchError: expected 1 arguments, instead got 0") do
        ret = fn.call([] of AnyValue)
      end
    end
  end
end
