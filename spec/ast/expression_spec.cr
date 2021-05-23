require "spec"
require "../../src/ast/expression.cr"

include FayrantLang
include AST

describe "FayrantLang::AST Expressions" do
  describe "LiteralExpr" do
    describe "BooleanLiteralExpr" do
      it "two BooleanLiteralExpr should be comparable" do
        ex1 = BooleanLiteralExpr.new true
        ex2 = BooleanLiteralExpr.new true
        ex3 = BooleanLiteralExpr.new false
        ex4 = BooleanLiteralExpr.new false

        ex1.should eq ex1
        ex1.should eq ex2
        ex2.should_not eq ex3
        (ex3 == ex4).should eq true
        (ex4 == ex4).should eq true
      end

      it "BooleanLiteralExpr should evaluate to BooleanValue" do
        ex1 = BooleanLiteralExpr.new true
        ex2 = BooleanLiteralExpr.new false

        (ex1.eval(Nil) == BooleanValue.new true).should eq true
        (ex1.eval(Nil) == BooleanValue.new false).should eq false
        (ex2.eval(Nil) == BooleanValue.new false).should eq true
      end
    end

    describe "NumberLiteralExpr" do
      it "two NumberLiteralExpr should be comparable" do
        ex1 = NumberLiteralExpr.new 3
        ex2 = NumberLiteralExpr.new 3
        ex3 = NumberLiteralExpr.new 7
        ex4 = NumberLiteralExpr.new 7

        (ex1 == ex1).should eq true
        (ex1 == ex2).should eq true
        (ex2 == ex3).should eq false
        (ex3 == ex4).should eq true
        (ex4 == ex4).should eq true
      end

      it "NumberLiteralExpr should evaluate to NumberValue" do
        ex1 = NumberLiteralExpr.new 3
        ex2 = NumberLiteralExpr.new 7

        (ex1.eval(Nil) == NumberValue.new 3).should eq true
        (ex1.eval(Nil) == NumberValue.new 7).should eq false
        (ex2.eval(Nil) == NumberValue.new 7).should eq true
      end
    end

    describe "NullLiteralExpr" do
        it "two NullLiteralExpr should be equal" do
          ex1 = NullLiteralExpr.new
          ex2 = NullLiteralExpr.new
  
          ex1.should eq ex2
        end
  
        it "NullLiteralExpr should evaluate to NullValue" do
          ex = NullLiteralExpr.new
          ex.eval(Nil).should eq NullValue.new
        end
      end
  end
end
