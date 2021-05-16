require "spec"
require "../src/lexer.cr"

include FayrantLang

describe "FayrantLang Lexer" do
  # TODO
  # - add more tests
  # - group and refactor them

  it "should tokenize 'var test = 2 + 3.14;'" do
    input = "var test = 2 + 3.14;"
    #        0123456789
    #                  0123456789
    result = Lexer.new(input).scan_tokens
    expected = [
      Token.new(TokenType::VAR, "var", Location.new 1, 0, 2),
      Token.new(TokenType::IDENTIFIER, "test", Location.new 1, 4, 7),
      Token.new(TokenType::EQUAL, "=", Location.new 1, 9, 9),
      Token.new(TokenType::NUMBER, "2", Location.new 1, 11, 11),
      Token.new(TokenType::OP_PLUS, "+", Location.new 1, 13, 13),
      Token.new(TokenType::NUMBER, "3.14", Location.new 1, 15, 18),
      Token.new(TokenType::SEMICOLON, ";", Location.new 1, 19, 19),
    ]
    result.zip?(expected) do |res, exp|
      res.should eq exp
    end
  end

  it "should tokenize '(2 + 2) ++ 0xDEADBEEF;'" do
    input = "(2 + 2) ++ 0xDEADBEEF;"
    #        0123456789          01
    #                  0123456789
    result = Lexer.new(input).scan_tokens
    expected = [
      Token.new(TokenType::L_PAREN, "(", Location.new 1, 0, 0),
      Token.new(TokenType::NUMBER, "2", Location.new 1, 1, 1),
      Token.new(TokenType::OP_PLUS, "+", Location.new 1, 3, 3),
      Token.new(TokenType::NUMBER, "2", Location.new 1, 5, 5),
      Token.new(TokenType::R_PAREN, ")", Location.new 1, 6, 6),      
      Token.new(TokenType::OP_CONCAT, "++", Location.new 1, 8, 9),
      Token.new(TokenType::NUMBER, "0xDEADBEEF", Location.new 1, 11, 20),
      Token.new(TokenType::SEMICOLON, ";", Location.new 1, 21, 21),
    ]
    result.zip?(expected) do |res, exp|
      res.should eq exp
    end
  end

  # multiline code

  it "should tokenize '\"test\";'" do
    input = "\"test\";"
    #         01234 56
    result = Lexer.new(input).scan_tokens
    expected = [
      Token.new(TokenType::QUOTE, "\"", Location.new 1, 0, 0),
      Token.new(TokenType::STRING_FRAGMENT, "test", Location.new 1, 1, 4),
      Token.new(TokenType::QUOTE, "\"", Location.new 1, 5, 5),
      Token.new(TokenType::SEMICOLON, ";", Location.new 1, 6, 6),
    ]
    result.zip?(expected) do |res, exp|
      res.should eq exp
    end
  end

  it "should tokenize '\"te\\st\";'" do
    input = "\"te\\nst\";"
    #         012 3456 78
    result = Lexer.new(input).scan_tokens
    expected = [
      Token.new(TokenType::QUOTE, "\"", Location.new 1, 0, 0),
      Token.new(TokenType::STRING_FRAGMENT, "te\nst", Location.new 1, 1, 6),
      Token.new(TokenType::QUOTE, "\"", Location.new 1, 7, 7),
      Token.new(TokenType::SEMICOLON, ";", Location.new 1, 8, 8),
    ]
    result.zip?(expected) do |res, exp|
      res.should eq exp
    end
  end

  it "should tokenize '\"test1{ \"test2{\"test3\" }test4\"} test5\"'" do
    input = "\"test1{ \"test2{\"test3\" }test4\"} test5\""
    #         01234567 89           0 12345678 9
    #                    01234 56789            0123456 7
    result = Lexer.new(input).scan_tokens
    expected = [
      Token.new(TokenType::QUOTE, "\"", Location.new 1, 0, 0),
      Token.new(TokenType::STRING_FRAGMENT, "test1", Location.new 1, 1, 5),
      Token.new(TokenType::L_BRACE, "{", Location.new 1, 6, 6),
      Token.new(TokenType::QUOTE, "\"", Location.new 1, 8, 8),
      Token.new(TokenType::STRING_FRAGMENT, "test2", Location.new 1, 9, 13),
      Token.new(TokenType::L_BRACE, "{", Location.new 1, 14, 14),
      Token.new(TokenType::QUOTE, "\"", Location.new 1, 15, 15),
      Token.new(TokenType::STRING_FRAGMENT, "test3", Location.new 1, 16, 20),
      Token.new(TokenType::QUOTE, "\"", Location.new 1, 21, 21),
      Token.new(TokenType::R_BRACE, "}", Location.new 1, 23, 23),
      Token.new(TokenType::STRING_FRAGMENT, "test4", Location.new 1, 24, 28),
      Token.new(TokenType::QUOTE, "\"", Location.new 1, 29, 29),
      Token.new(TokenType::R_BRACE, "}", Location.new 1, 30, 30),
      Token.new(TokenType::STRING_FRAGMENT, " test5", Location.new 1, 31, 36),
      Token.new(TokenType::QUOTE, "\"", Location.new 1, 37, 37),
    ]
    result.zip?(expected) do |res, exp|
      res.should eq exp
    end
  end

  it "should tokenize '\"test\\u{65}\";'" do
    input = "\"test\\u{65}\";"
    #         01234 56789
    #                    0 12
    # result = Lexer.new(input).scan_tokens
    expected = [
      Token.new(TokenType::QUOTE, "\"", Location.new 1, 0, 0),
      Token.new(TokenType::STRING_FRAGMENT, "testA", Location.new 1, 1, 10),
      Token.new(TokenType::QUOTE, "\"", Location.new 1, 11, 11),
      Token.new(TokenType::SEMICOLON, ";", Location.new 1, 12, 12),
    ]
    # result.zip?(expected) do |res, exp|
    #   res.should eq exp
    # end
  end

  it "should tokenize simple tokens" do
    lexer = Lexer.new ""
    lexer.test_single_token("va").should eq TokenType::IDENTIFIER
    lexer.test_single_token("var").should eq TokenType::VAR
    lexer.test_single_token("vars").should eq TokenType::IDENTIFIER

    lexer.test_single_token("++").should eq TokenType::OP_CONCAT
    lexer.test_single_token("+").should eq TokenType::OP_PLUS

    lexer.test_single_token("=").should eq TokenType::EQUAL
    lexer.test_single_token("==").should eq TokenType::OP_EQ

    lexer.test_single_token("!").should eq TokenType::OP_NEG
    lexer.test_single_token("!=").should eq TokenType::OP_NEQ

    lexer.test_single_token("<").should eq TokenType::OP_LT
    lexer.test_single_token("<=").should eq TokenType::OP_LE

    lexer.test_single_token(">").should eq TokenType::OP_GT
    lexer.test_single_token(">=").should eq TokenType::OP_GE
  end
end
