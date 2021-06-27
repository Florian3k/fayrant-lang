require "spec"
require "../../src/interpreter/context.cr"

include FayrantLang

describe "FayrantLang Context" do
  it "should return created variable" do
    ctx = Context.new

    ctx.create_var "asdf", NumberValue.new(7)
    (ctx.get_var("asdf") == NumberValue.new(7)).should eq true

    ctx.set_var "asdf", NumberValue.new(8)
    (ctx.get_var("asdf") == NumberValue.new(8)).should eq true
  end

  it "should return variable from parent context" do
    parent = Context.new
    parent.create_var "asdf", NumberValue.new(7)
    ctx = Context.new parent

    (ctx.get_var("asdf") == NumberValue.new(7)).should eq true
  end

  it "should return most recent variable in context" do
    parent = Context.new
    ctx = Context.new parent

    parent.create_var "asdf", NumberValue.new(7)
    ctx.create_var "asdf", NumberValue.new(8)

    (ctx.get_var("asdf") == NumberValue.new(8)).should eq true
  end

  it "should override only most recent variable in context" do
    parent = Context.new
    ctx = Context.new parent

    parent.create_var "asdf", NumberValue.new(7)
    ctx.create_var "asdf", NumberValue.new(8)

    (parent.get_var("asdf") == NumberValue.new(7)).should eq true
    (ctx.get_var("asdf") == NumberValue.new(8)).should eq true

    ctx.set_var "asdf", NumberValue.new(9)

    (parent.get_var("asdf") == NumberValue.new(7)).should eq true
    (ctx.get_var("asdf") == NumberValue.new(9)).should eq true
  end
end