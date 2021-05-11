require "spec"
require "../src/token.cr"

include FayrantLang

describe "FayrantLang Lexer" do
  # TODO
  # - add more tests
  # - group and refactor them

  it "should correctly tokenize 'var test = 2 + 2;'" do
    input = "var test = 2 + 3;"
    #        0123456789
    #                  01234567
    # result = lexer(input)
    expected = [
      Token.new(TokenType::VAR, "var", Location.new(1, 0, 2)),
      Token.new(TokenType::IDENTIFIER, "test", Location.new(1, 4, 7)),
      Token.new(TokenType::EQUAL, "=", Location.new(1, 9, 9)),
      Token.new(TokenType::NUMBER, "2", Location.new(1, 11, 11)),
      Token.new(TokenType::OP_PLUS, "+", Location.new(1, 13, 13)),
      Token.new(TokenType::NUMBER, "3", Location.new(1, 15, 15)),
      Token.new(TokenType::SEMICOLON, ";", Location.new(1, 13, 13)),
    ]
    # result.should eq expected
  end


  it "should correctly tokenize '\"test\\u{65}\";'" do
    input = "\"test\\u{65}\";"
    #         01234 56789
    #                    0 12
    # result = lexer(input)
    expected = [
      Token.new(TokenType::QUOTE, "\"", Location.new(1, 0, 0)),
      Token.new(TokenType::STRING_FRAGMENT, "testA", Location.new(1, 1, 10)),
      Token.new(TokenType::QUOTE, "\"", Location.new(1, 11, 11)),
      Token.new(TokenType::SEMICOLON, ";", Location.new(1, 12, 12)),
    ]
    # result.should eq expected
  end
end
