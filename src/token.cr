module FayrantLang
  enum TokenType
    FUNC
    CLASS
    CONSTRUCTOR
    IF
    ELSE
    WHILE
    FOR
    VAR
    RETURN

    IDENTIFIER

    L_BRACE
    R_BRACE
    L_PAREN
    R_PAREN
    DOT
    COMMA
    SEMICOLON
    QUOTE

    EQUAL
    EQUAL_PLUS
    EQUAL_MINUS
    EQUAL_TIMES
    EQUAL_DIV
    EQUAL_DIV_INV
    EQUAL_MOD
    EQUAL_EXPT
    EQUAL_AND
    EQUAL_OR
    EQUAL_CONCAT

    OP_MINUS  # unary and binary
    OP_NEG    # unary
    OP_TO_STR # unary
    OP_TO_NUM # unary
    OP_PLUS
    OP_TIMES
    OP_DIV
    OP_DIV_INV
    OP_MOD
    OP_EXPT
    OP_AND
    OP_OR
    OP_GT
    OP_LT
    OP_GE
    OP_LE
    OP_EQ
    OP_NEQ
    OP_CONCAT

    STRING_FRAGMENT
    NUMBER
    TRUE
    FALSE
    NULL
  end

  class Token
    getter type
    getter lexeme
    getter loc

    def initialize(@type : TokenType, @lexeme : String, @loc : Location)
    end

    def ==(other : Token)
      type == other.type && lexeme == other.lexeme && loc == other.loc
    end
  end

  class Location
    getter line
    getter from
    getter to

    def initialize(@line : Int32, @from : Int32, @to : Int32)
    end

    def ==(other : Location)
      line == other.line && from == other.from && to == other.to
    end
  end
end
