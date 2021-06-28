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

  it "should parse '0xC0DE + 0b1010;'" do
    tokens = Lexer.new("0xC0DE + 0b1010;").scan_tokens
    result = Parser.new(tokens).parse_program[0].as(ExprStatement).expr
    expected = BinaryExprPlus.new(
      NumberLiteralExpr.new(49374),
      NumberLiteralExpr.new(10)
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

  it "should parse '1.a(2, 3 + 4).b();'" do
    tokens = Lexer.new("1.a(2, 3 + 4).b();").scan_tokens
    result = Parser.new(tokens).parse_program[0].as(ExprStatement).expr
    expected = FunctionCallExpr.new(
      ObjectAccessExpr.new(
        FunctionCallExpr.new(
          ObjectAccessExpr.new(NumberLiteralExpr.new(1), "a"),
          [
            NumberLiteralExpr.new(2),
            BinaryExprPlus.new(NumberLiteralExpr.new(3), NumberLiteralExpr.new(4)),
          ],
        ),
        "b"
      ),
      [] of Expr,
    )
    result.should eq expected
  end

  it "should parse 'a.b + c * d;'" do
    tokens = Lexer.new("a.b + c * d;").scan_tokens
    result = Parser.new(tokens).parse_program[0].as(ExprStatement).expr
    expected = BinaryExprPlus.new(
      ObjectAccessExpr.new(VariableExpr.new("a"), "b"),
      BinaryExprMult.new(VariableExpr.new("c"), VariableExpr.new("d")),
    )
    result.should eq expected
  end

  it "should parse 'a + b; 1 + 2;'" do
    tokens = Lexer.new("a + b; 1 + 2;").scan_tokens
    result = Parser.new(tokens).parse_program
    expected = [
      ExprStatement.new(
        BinaryExprPlus.new(VariableExpr.new("a"), VariableExpr.new("b"))
      ),
      ExprStatement.new(
        BinaryExprPlus.new(NumberLiteralExpr.new(1), NumberLiteralExpr.new(2))
      ),
    ]
    result.zip?(expected) do |res, exp|
      res.should eq exp
    end
  end

  it "should parse 'var x = 1 + 2;'" do
    tokens = Lexer.new("var x = 1 + 2;").scan_tokens
    result = Parser.new(tokens).parse_program[0].as(VariableDeclarationStatement)
    expected = VariableDeclarationStatement.new(
      "x",
      BinaryExprPlus.new(NumberLiteralExpr.new(1), NumberLiteralExpr.new(2)),
    )
    result.should eq expected
  end

  it "should parse '\"abc{ 1 + 2 }def\";'" do
    tokens = Lexer.new("\"abc{ 1 + 2 }def\";").scan_tokens
    result = Parser.new(tokens).parse_program[0].as(ExprStatement).expr
    expected = StringLiteralExpr.new([
      StringLiteralFragment.new("abc"),
      StringInterpolationFragment.new(
        BinaryExprPlus.new(NumberLiteralExpr.new(1), NumberLiteralExpr.new(2))
      ),
      StringLiteralFragment.new("def"),
    ])
    result.should eq expected
  end

  it "should parse '\"abc{ \"def{ 1 + 2 }\" ++ \"ghi\" }jkl\";'" do
    tokens = Lexer.new("\"abc{ \"def{ 1 + 2 }\" ++ \"ghi\" }jkl\";").scan_tokens
    result = Parser.new(tokens).parse_program[0].as(ExprStatement).expr
    expected = StringLiteralExpr.new([
      StringLiteralFragment.new("abc"),
      StringInterpolationFragment.new(
        BinaryExprConcat.new(
          StringLiteralExpr.new([
            StringLiteralFragment.new("def"),
            StringInterpolationFragment.new(
              BinaryExprPlus.new(NumberLiteralExpr.new(1), NumberLiteralExpr.new(2))
            ),
          ]),
          StringLiteralExpr.new([StringLiteralFragment.new("ghi")] of StringFragment)
        ),
      ),
      StringLiteralFragment.new("jkl"),
    ])
    result.should eq expected
  end

  it "should parse 'if (true) { print(5); 7; }'" do
    tokens = Lexer.new("if (true) { print(5); 7; }").scan_tokens
    result = Parser.new(tokens).parse_program[0].as(IfStatement)
    expected = IfStatement.new(
      BooleanLiteralExpr.new(true),
      [
        ExprStatement.new(
          FunctionCallExpr.new(
            VariableExpr.new("print"),
            [NumberLiteralExpr.new(5)] of Expr,
          )
        ),
        ExprStatement.new(NumberLiteralExpr.new(7)),
      ] of Statement,
      [] of Statement,
    )
    result.should eq expected
  end

  it "should parse 'if (true) { } else { print(5); 7; }'" do
    tokens = Lexer.new("if (true) { } else { print(5); 7; }").scan_tokens
    result = Parser.new(tokens).parse_program[0].as(IfStatement)
    expected = IfStatement.new(
      BooleanLiteralExpr.new(true),
      [] of Statement,
      [
        ExprStatement.new(
          FunctionCallExpr.new(
            VariableExpr.new("print"),
            [NumberLiteralExpr.new(5)] of Expr,
          )
        ),
        ExprStatement.new(NumberLiteralExpr.new(7)),
      ] of Statement,
    )
    result.should eq expected
  end

  it "should parse 'while (true) { print(5); }'" do
    tokens = Lexer.new("while (true) { print(5); }").scan_tokens
    result = Parser.new(tokens).parse_program[0].as(WhileStatement)
    expected = WhileStatement.new(
      BooleanLiteralExpr.new(true),
      [
        ExprStatement.new(
          FunctionCallExpr.new(
            VariableExpr.new("print"),
            [NumberLiteralExpr.new(5)] of Expr,
          )
        ),
      ] of Statement,
    )
    result.should eq expected
  end

  it "should parse 'for (;;) { print(5); }'" do
    tokens = Lexer.new("for (;;) { print(5); }").scan_tokens
    result = Parser.new(tokens).parse_program[0].as(ForStatement)
    expected = ForStatement.new(
      EmptyStatement.new,
      BooleanLiteralExpr.new(true),
      EmptyStatement.new,
      [
        ExprStatement.new(
          FunctionCallExpr.new(
            VariableExpr.new("print"),
            [NumberLiteralExpr.new(5)] of Expr,
          )
        ),
      ] of Statement,
    )
    result.should eq expected
  end

  it "should parse 'for (var x = 0; x < 5; x += 1) { print(x); }'" do
    tokens = Lexer.new("for (var x = 0; x < 5; x += 1) { print(x); }").scan_tokens
    result = Parser.new(tokens).parse_program[0].as(ForStatement)
    expected = ForStatement.new(
      VariableDeclarationStatement.new(
        "x",
        NumberLiteralExpr.new(0),
      ),
      BinaryExprLt.new(VariableExpr.new("x"), NumberLiteralExpr.new(5)),
      VariableAssignmentStatement.new(
        "x",
        BinaryExprPlus.new(VariableExpr.new("x"), NumberLiteralExpr.new(1))
      ),
      [
        ExprStatement.new(
          FunctionCallExpr.new(
            VariableExpr.new("print"),
            [VariableExpr.new("x")] of Expr,
          )
        ),
      ] of Statement,
    )
    result.should eq expected
  end

  it "should parse 'break;'" do
    tokens = Lexer.new("break;").scan_tokens
    result = Parser.new(tokens).parse_program[0].as(BreakStatement)
    expected = BreakStatement.new
    result.should eq expected
  end

  it "should parse 'continue;'" do
    tokens = Lexer.new("continue;").scan_tokens
    result = Parser.new(tokens).parse_program[0].as(ContinueStatement)
    expected = ContinueStatement.new
    result.should eq expected
  end

  it "should parse simple function" do
    tokens = Lexer.new("func test() {}").scan_tokens
    result = Parser.new(tokens).parse_program[0].as(FunctionDeclarationStatement)
    expected = FunctionDeclarationStatement.new(
      "test",
      [] of String,
      [] of Statement,
    )
    result.should eq expected
  end

  it "should parse function with params and return statement" do
    input = "func test(a, b) {\n" \
            "  var x = a + b; \n" \
            "  return x + 3;  \n" \
            "  return;        \n" \
            "}"
    tokens = Lexer.new(input).scan_tokens
    result = Parser.new(tokens).parse_program[0].as(FunctionDeclarationStatement)
    expected = FunctionDeclarationStatement.new(
      "test",
      ["a", "b"],
      [
        VariableDeclarationStatement.new(
          "x",
          BinaryExprPlus.new(VariableExpr.new("a"), VariableExpr.new("b")),
        ),
        ReturnStatement.new(
          BinaryExprPlus.new(VariableExpr.new("x"), NumberLiteralExpr.new(3))
        ),
        ReturnStatement.new(NullLiteralExpr.new),
      ],
    )
    result.should eq expected
  end

  it "should parse 'x = 1 + 2;'" do
    tokens = Lexer.new("x = 1 + 2;").scan_tokens
    result = Parser.new(tokens).parse_program[0].as(VariableAssignmentStatement)
    expected = VariableAssignmentStatement.new(
      "x",
      BinaryExprPlus.new(NumberLiteralExpr.new(1), NumberLiteralExpr.new(2)),
    )
    result.should eq expected
  end

  it "should parse 'x += 2;'" do
    tokens = Lexer.new("x += 2;").scan_tokens
    result = Parser.new(tokens).parse_program[0].as(VariableAssignmentStatement)
    expected = VariableAssignmentStatement.new(
      "x",
      BinaryExprPlus.new(VariableExpr.new("x"), NumberLiteralExpr.new(2)),
    )
    result.should eq expected
  end

  it "should parse 'this.x = 1 + 2;'" do
    tokens = Lexer.new("this.x = 1 + 2;").scan_tokens
    result = Parser.new(tokens).parse_program[0].as(ObjectFieldAssignmentStatement)
    expected = ObjectFieldAssignmentStatement.new(
      VariableExpr.new("this"),
      "x",
      BinaryExprPlus.new(NumberLiteralExpr.new(1), NumberLiteralExpr.new(2)),
    )
    result.should eq expected
  end

  it "should parse 'this.x += 2;'" do
    tokens = Lexer.new("this.x += 2;").scan_tokens
    result = Parser.new(tokens).parse_program[0].as(ObjectFieldAssignmentStatement)
    expected = ObjectFieldAssignmentStatement.new(
      VariableExpr.new("this"),
      "x",
      BinaryExprPlus.new(
        ObjectAccessExpr.new(VariableExpr.new("this"), "x"),
        NumberLiteralExpr.new(2)
      ),
    )
    result.should eq expected
  end

  it "should parse class declaration" do
    input = "class TestClass {     \n" \
            "  constructor(a, b) { \n" \
            "    this.x = a;       \n" \
            "    this.y = b;       \n" \
            "  }                   \n" \
            "  func test() { }     \n" \
            "  func test2(a, b) {  \n" \
            "    return this.x * a;\n" \
            "  }                   \n" \
            "}                     \n"
    tokens = Lexer.new(input).scan_tokens
    result = Parser.new(tokens).parse_program[0].as(ClassDeclarationStatement)
    expected = ClassDeclarationStatement.new(
      "TestClass",
      ["a", "b"],
      [
        ObjectFieldAssignmentStatement.new(VariableExpr.new("this"), "x", VariableExpr.new("a")),
        ObjectFieldAssignmentStatement.new(VariableExpr.new("this"), "y", VariableExpr.new("b")),
      ] of Statement,
      [
        FunctionDeclarationStatement.new("test", [] of String, [] of Statement),
        FunctionDeclarationStatement.new(
          "test2",
          ["a", "b"],
          [
            ReturnStatement.new(
              BinaryExprMult.new(
                ObjectAccessExpr.new(
                  VariableExpr.new("this"),
                  "x"
                ),
                VariableExpr.new("a"),
              )
            ),
          ] of Statement
        ),
      ]
    )
    result.should eq expected
  end
end
