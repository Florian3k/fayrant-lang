require "spec"
require "../../src/parser/parser.cr"
require "../../src/parser/lexer.cr"

include FayrantLang

describe "FayrantLang Parser" do
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

  it "should parse '1 \\ 2 / 3 \\ 4;'" do
    tokens = Lexer.new("1 \\ 2 / 3 \\ 4;").scan_tokens
    result = Parser.new(tokens).parse_program[0].as(ExprStatement).expr
    expected = BinaryExprDivInv.new(
      NumberLiteralExpr.new(1),
      BinaryExprDivInv.new(
        BinaryExprDiv.new(
          NumberLiteralExpr.new(2),
          NumberLiteralExpr.new(3)
        ),
        NumberLiteralExpr.new(4)
      )
    )
    result.should eq expected
  end

  it "should parse '1 & 2 | 3 | 4 & 5;'" do
    tokens = Lexer.new("1 & 2 | 3 | 4 & 5;").scan_tokens
    result = Parser.new(tokens).parse_program[0].as(ExprStatement).expr
    expected = BinaryExprOr.new(
      BinaryExprOr.new(
        BinaryExprAnd.new(NumberLiteralExpr.new(1), NumberLiteralExpr.new(2)),
        NumberLiteralExpr.new(3),
      ),
      BinaryExprAnd.new(NumberLiteralExpr.new(4), NumberLiteralExpr.new(5)),
    )
    result.should eq expected
  end

  it "should parse '1 > 2 | 3 <= 4;'" do
    tokens = Lexer.new("1 > 2 | 3 <= 4;").scan_tokens
    result = Parser.new(tokens).parse_program[0].as(ExprStatement).expr
    expected = BinaryExprOr.new(
      BinaryExprGt.new(NumberLiteralExpr.new(1), NumberLiteralExpr.new(2)),
      BinaryExprLe.new(NumberLiteralExpr.new(3), NumberLiteralExpr.new(4)),
    )
    result.should eq expected
  end

  it "should parse '1 ++ 2 ++ 3;'" do
    tokens = Lexer.new("1 ++ 2 ++ 3;").scan_tokens
    result = Parser.new(tokens).parse_program[0].as(ExprStatement).expr
    expected = BinaryExprConcat.new(
      BinaryExprConcat.new(NumberLiteralExpr.new(1), NumberLiteralExpr.new(2)),
      NumberLiteralExpr.new(3),
    )
    result.should eq expected
  end

  it "should parse '2 ^ 3 ^ 4;'" do
    tokens = Lexer.new("2 ^ 3 ^ 4;").scan_tokens
    result = Parser.new(tokens).parse_program[0].as(ExprStatement).expr
    expected = BinaryExprExpt.new(
      NumberLiteralExpr.new(2),
      BinaryExprExpt.new(NumberLiteralExpr.new(3), NumberLiteralExpr.new(4)),
    )
    result.should eq expected
  end
end
