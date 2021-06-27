require "../ast/expression.cr"
require "../ast/statement.cr"

module FayrantLang
  include AST

  class Parser
    def initialize(@tokens : Array(Token))
      @index = 0
    end

    def parse_program
      statements = [] of Statement
      until eof
        statements << parse_statement
      end
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
      parse_expr_or
    end

    private def parse_expr_or
      expr = parse_expr_and
      while true
        if currentToken.type == TokenType::OP_OR
          consumeToken TokenType::OP_OR
          expr = BinaryExprOr.new expr, parse_expr_and
        else
          break
        end
      end
      expr
    end

    private def parse_expr_and
      expr = parse_expr_equality
      while true
        if currentToken.type == TokenType::OP_AND
          consumeToken TokenType::OP_AND
          expr = BinaryExprAnd.new expr, parse_expr_equality
        else
          break
        end
      end
      expr
    end

    private def parse_expr_equality
      expr = parse_expr_compare
      while true
        case currentToken.type
        when TokenType::OP_EQ
          consumeToken TokenType::OP_EQ
          expr = BinaryExprEq.new expr, parse_expr_compare
        when TokenType::OP_NEQ
          consumeToken TokenType::OP_NEQ
          expr = BinaryExprNeq.new expr, parse_expr_compare
        else
          break
        end
      end
      expr
    end

    private def parse_expr_compare
      expr = parse_expr_concat
      while true
        case currentToken.type
        when TokenType::OP_GT
          consumeToken TokenType::OP_GT
          expr = BinaryExprGt.new expr, parse_expr_concat
        when TokenType::OP_LT
          consumeToken TokenType::OP_LT
          expr = BinaryExprLt.new expr, parse_expr_concat
        when TokenType::OP_GE
          consumeToken TokenType::OP_GE
          expr = BinaryExprGe.new expr, parse_expr_concat
        when TokenType::OP_LE
          consumeToken TokenType::OP_LE
          expr = BinaryExprLe.new expr, parse_expr_concat
        else
          break
        end
      end
      expr
    end

    private def parse_expr_concat
      expr = parse_expr_plus_minus
      while true
        if currentToken.type == TokenType::OP_CONCAT
          consumeToken TokenType::OP_CONCAT
          expr = BinaryExprConcat.new expr, parse_expr_plus_minus
        else
          break
        end
      end
      expr
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
      expr = parse_expr_expt
      while true
        case currentToken.type
        when TokenType::OP_TIMES
          consumeToken TokenType::OP_TIMES
          expr = BinaryExprMult.new expr, parse_expr_expt
        when TokenType::OP_DIV
          consumeToken TokenType::OP_DIV
          expr = BinaryExprDiv.new expr, parse_expr_expt
        when TokenType::OP_MOD
          consumeToken TokenType::OP_MOD
          expr = BinaryExprMod.new expr, parse_expr_expt
        else
          break
        end
      end
      expr
    end

    private def parse_expr_expt
      expr = parse_expr_unary
      if currentToken.type == TokenType::OP_EXPT
        consumeToken TokenType::OP_EXPT
        BinaryExprExpt.new expr, parse_expr_expt
      else
        expr
      end
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
        parse_expr_call_access
      end
    end

    private def parse_expr_call_access
      expr = parse_expr_basic
      while true
        case currentToken.type
        when TokenType::DOT
          consumeToken TokenType::DOT
          identifier = consumeToken TokenType::IDENTIFIER
          expr = ObjectAccessExpr.new expr, identifier.lexeme
        when TokenType::L_PAREN
          consumeToken TokenType::L_PAREN
          args = [] of Expr
          while currentToken.type != TokenType::R_PAREN
            args << parse_expr
            if currentToken.type == TokenType::R_PAREN
              break
            end
            consumeToken TokenType::COMMA
          end
          consumeToken TokenType::R_PAREN
          expr = FunctionCallExpr.new expr, args
        else
          break
        end
      end
      expr
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
        VariableExpr.new token.lexeme
      when TokenType::NUMBER
        token = consumeToken TokenType::NUMBER
        case token.lexeme[0..1]
        when "0x"
          NumberLiteralExpr.new token.lexeme[2..].to_i(16).to_f
        when "0b"
          NumberLiteralExpr.new token.lexeme[2..].to_i(2).to_f
        else
          NumberLiteralExpr.new token.lexeme.to_f
        end
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

    private def eof
      return @index >= @tokens.size
    end

    private def currentToken
      return @tokens[@index]
    end

    private def consumeToken(tt : TokenType)
      if eof
        raise Exception.new "Unexpected end of input, expected #{tt}"
      elsif @tokens[@index].type == tt
        @index += 1
        return @tokens[@index - 1]
      else
        raise Exception.new "Unexpected token #{currentToken.type}: #{currentToken.lexeme}, expected #{tt}"
      end
    end
  end
end
