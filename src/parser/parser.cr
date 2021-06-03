require "../token.cr"
require "../ast/expression.cr"
require "../ast/statement.cr"

module FayrantLang
  class Parser
    def initialize(@tokens : Array(Token))
      @index = 0
    end

    def parse_program
      statements = [] of Statement
      #TODO
      statements << parse_statement
      statements
    end

    private def parse_statement
      # TODO
      parse_expr_statement
    end

    private def parse_expr_statement
      expr = parse_expr
      consumeToken TokenType::SEMICOLON
      ExprStatement.new expr
    end

    private def parse_expr
      # TODO
      parse_expr_plus_minus
    end

    private def parse_expr_plus_minus
      expr = parse_expr_div_inv
      while true
        case currentToken.type
        when TokenType::OP_PLUS
          consumeToken TokenType::OP_PLUS
          expr = BinaryExprPlus.new expr, parse_expr_div_inv
        when TokenType::OP_MINUS
          consumeToken TokenType::OP_MINUS
          expr = BinaryExprMinus.new expr, parse_expr_div_inv
        else
          break
        end
      end
      expr
    end

    private def parse_expr_div_inv
      expr = parse_expr_times_div_mod
      if currentToken.type == TokenType::OP_DIV_INV
        consumeToken TokenType::OP_DIV_INV
        BinaryExprDivInv.new expr, parse_expr_div_inv
      else
        expr
      end
    end

    private def parse_expr_times_div_mod
      expr = parse_expr_unary
      while true
        case currentToken.type
        when TokenType::OP_TIMES
          consumeToken TokenType::OP_TIMES
          expr = BinaryExprMult.new expr, parse_expr_unary
        when TokenType::OP_DIV
          consumeToken TokenType::OP_DIV
          expr = BinaryExprDiv.new expr, parse_expr_unary
        when TokenType::OP_MOD
          consumeToken TokenType::OP_MOD
          expr = BinaryExprMod.new expr, parse_expr_unary
        else
          break
        end
      end
      expr
    end

    private def parse_expr_unary
      case currentToken.type
      when TokenType::OP_MINUS
        consumeToken TokenType::OP_MINUS
        UnaryExprMinus.new parse_expr_unary
      when TokenType::OP_NEG
        consumeToken TokenType::OP_NEG
        UnaryExprNegation.new parse_expr_unary
      when TokenType::OP_TO_STR
        consumeToken TokenType::OP_TO_STR
        UnaryExprToString.new parse_expr_unary
      when TokenType::OP_TO_NUM
        consumeToken TokenType::OP_TO_NUM
        UnaryExprToNumber.new parse_expr_unary
      else
        parse_expr_basic
      end
    end

    private def parse_expr_basic
      case currentToken.type
      when TokenType::L_PAREN
        consumeToken TokenType::L_PAREN
        expr = parse_expr
        consumeToken TokenType::R_PAREN
        expr
      when TokenType::IDENTIFIER
        token = consumeToken TokenType::IDENTIFIER
        # TODO
        raise Exception.new "Variable expression are not implemented yet"
      when TokenType::NUMBER
        token = consumeToken TokenType::NUMBER
        # TODO handle 0x and 0b literals
        NumberLiteralExpr.new token.lexeme.to_f
      when TokenType::TRUE
        consumeToken TokenType::TRUE
        BooleanLiteralExpr.new true
      when TokenType::FALSE
        consumeToken TokenType::FALSE
        BooleanLiteralExpr.new false
      when TokenType::NULL
        consumeToken TokenType::NULL
        NullLiteralExpr.new
      when TokenType::QUOTE
        # TODO
        raise Exception.new "String literals are not implemented yet"
      else
        # TODO
        raise Exception.new "Unexpected token #{currentToken.type}: #{currentToken.lexeme} "
      end
    end

    private def currentToken
      return @tokens[@index]
    end

    private def consumeToken(tt : TokenType)
      if @tokens[@index].type == tt
        @index += 1
        return @tokens[@index - 1]
      end
      raise Exception.new "Unexpected token #{currentToken.type}: #{currentToken.lexeme} "
    end
  end
end
