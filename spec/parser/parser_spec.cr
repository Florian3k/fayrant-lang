require "spec"
require "../../src/parser/parser.cr"
require "../../src/lexer.cr"

include FayrantLang

describe "FayrantLang Parser", focus: true do
  it "should parse '2 + 3 / 4;'" do
    tokens = Lexer.new("2 + 3 / 4;").scan_tokens
    result = Parser.new(tokens).parse_program[0].as(ExprStatement).expr
    expected = BinaryExprPlus.new(
      NumberLiteralExpr.new(2),
      BinaryExprDiv.new(
        NumberLiteralExpr.new(3),
        NumberLiteralExpr.new(4)
      )
    )
    result.should eq expected
  end

  it "should parse '(2 + 3) / 4;'" do
    tokens = Lexer.new("(2 + 3) / 4;").scan_tokens
    result = Parser.new(tokens).parse_program[0].as(ExprStatement).expr
    expected = BinaryExprDiv.new(
      BinaryExprPlus.new(
        NumberLiteralExpr.new(2),
        NumberLiteralExpr.new(3)),
      NumberLiteralExpr.new(4)
    )
    result.should eq expected
  end

  it "should parse '2 + @#!-7;'" do
    tokens = Lexer.new("2 + @#!-7;").scan_tokens
    result = Parser.new(tokens).parse_program[0].as(ExprStatement).expr
    expected =
      BinaryExprPlus.new(
        NumberLiteralExpr.new(2),
        UnaryExprToString.new(
          UnaryExprToNumber.new(
            UnaryExprNegation.new(
              UnaryExprMinus.new(
                NumberLiteralExpr.new(7),
              )
            )
          )
        )
      )
    result.should eq expected
  end
end
