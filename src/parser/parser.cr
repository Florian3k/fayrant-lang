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

    private def parse_statement : Statement
      case current_token.type
      when TokenType::FUNC
        parse_function_statement
      when TokenType::CLASS
        parse_class_statement
      when TokenType::IF
        parse_if_statement
      when TokenType::WHILE
        parse_while_statement
      when TokenType::FOR
        parse_for_statement
      when TokenType::VAR
        parse_var_statement
      when TokenType::RETURN
        parse_return_statement
      when TokenType::BREAK
        parse_break_statement
      when TokenType::CONTINUE
        parse_continue_statement
      else
        parse_expr_or_assignment_statement
      end
    end

    private def parse_function_statement
      consume_token TokenType::FUNC
      name_token = consume_token TokenType::IDENTIFIER
      params = parse_params
      body = parse_body
      FunctionDeclarationStatement.new name_token.lexeme, params, body
    end

    private def parse_class_statement
      consume_token TokenType::CLASS
      name_token = consume_token TokenType::IDENTIFIER
      consume_token TokenType::L_BRACE

      consume_token TokenType::CONSTRUCTOR
      ctor_params = parse_params
      ctor_body = parse_body

      methods = [] of FunctionDeclarationStatement
      while current_token.type != TokenType::R_BRACE
        methods << parse_function_statement
      end

      consume_token TokenType::R_BRACE

      ClassDeclarationStatement.new name_token.lexeme, ctor_params, ctor_body, methods
    end

    private def parse_if_statement
      consume_token TokenType::IF
      consume_token TokenType::L_PAREN
      cond = parse_expr
      consume_token TokenType::R_PAREN
      true_body = parse_body
      false_body = [] of Statement
      if !eof && current_token.type == TokenType::ELSE
        consume_token TokenType::ELSE
        false_body = parse_body
      end
      IfStatement.new cond, true_body, false_body
    end

    private def parse_while_statement
      consume_token TokenType::WHILE
      consume_token TokenType::L_PAREN
      cond = parse_expr
      consume_token TokenType::R_PAREN
      body = parse_body
      WhileStatement.new cond, body
    end

    private def parse_for_statement
      consume_token TokenType::FOR
      consume_token TokenType::L_PAREN

      init =
        case current_token.type
        when TokenType::SEMICOLON
          consume_token TokenType::SEMICOLON
          EmptyStatement.new
        when TokenType::VAR
          parse_var_statement
        else
          parse_expr_or_assignment_statement
        end

      cond =
        if current_token.type == TokenType::SEMICOLON
          BooleanLiteralExpr.new true
        else
          parse_expr
        end
      consume_token TokenType::SEMICOLON

      step =
        if current_token.type == TokenType::R_PAREN
          EmptyStatement.new
        else
          parse_expr_or_assignment_statement_no_semicolon
        end

      consume_token TokenType::R_PAREN

      body = parse_body

      ForStatement.new init, cond, step, body
    end

    private def parse_var_statement
      consume_token TokenType::VAR
      token = consume_token TokenType::IDENTIFIER
      expr =
        if current_token == TokenType::SEMICOLON
          NullLiteralExpr.new
        else
          consume_token TokenType::EQUAL
          parse_expr
        end
      consume_token TokenType::SEMICOLON
      VariableDeclarationStatement.new token.lexeme, expr
    end

    private def parse_expr_or_assignment_statement : Statement
      statement = parse_expr_or_assignment_statement_no_semicolon
      consume_token TokenType::SEMICOLON
      statement
    end

    private def parse_expr_or_assignment_statement_no_semicolon : Statement
      expr = parse_expr
      case
      when current_token.type == TokenType::SEMICOLON
        ExprStatement.new expr
      when current_token.type == TokenType::R_PAREN
        ExprStatement.new expr
      when expr.is_a?(VariableExpr)
        rhs_expr = parse_assignment_statement_expr expr
        VariableAssignmentStatement.new expr.name, rhs_expr
      when expr.is_a?(ObjectAccessExpr)
        rhs_expr = parse_assignment_statement_expr expr
        ObjectFieldAssignmentStatement.new expr.obj, expr.field, rhs_expr
      else
        raise SyntaxError.new "Expected semicolon or assignment operator"
        EmptyStatement.new
      end
    end

    private def parse_assignment_statement_expr(lhs : Expr) : Expr
      map = {
        TokenType::EQUAL         => ->(rhs : Expr) { rhs },
        TokenType::EQUAL_PLUS    => ->(rhs : Expr) { BinaryExprPlus.new(lhs, rhs) },
        TokenType::EQUAL_MINUS   => ->(rhs : Expr) { BinaryExprMinus.new(lhs, rhs) },
        TokenType::EQUAL_TIMES   => ->(rhs : Expr) { BinaryExprMult.new(lhs, rhs) },
        TokenType::EQUAL_DIV     => ->(rhs : Expr) { BinaryExprDiv.new(lhs, rhs) },
        TokenType::EQUAL_DIV_INV => ->(rhs : Expr) { BinaryExprDivInv.new(lhs, rhs) },
        TokenType::EQUAL_MOD     => ->(rhs : Expr) { BinaryExprMod.new(lhs, rhs) },
        TokenType::EQUAL_EXPT    => ->(rhs : Expr) { BinaryExprExpt.new(lhs, rhs) },
        TokenType::EQUAL_AND     => ->(rhs : Expr) { BinaryExprAnd.new(lhs, rhs) },
        TokenType::EQUAL_OR      => ->(rhs : Expr) { BinaryExprOr.new(lhs, rhs) },
        TokenType::EQUAL_CONCAT  => ->(rhs : Expr) { BinaryExprConcat.new(lhs, rhs) },
      }
      token = current_token
      unless map.has_key?(token.type)
        raise SyntaxError.new "Unexpected token #{token.type}: #{token.lexeme}, expected assignment operator"
      end
      assign_op = consume_token token.type
      rhs = parse_expr
      map[token.type].call(rhs)
    end

    private def parse_return_statement
      consume_token TokenType::RETURN
      expr = NullLiteralExpr.new
      if current_token.type != TokenType::SEMICOLON
        expr = parse_expr
      end
      consume_token TokenType::SEMICOLON
      ReturnStatement.new expr
    end

    private def parse_break_statement
      consume_token TokenType::BREAK
      consume_token TokenType::SEMICOLON
      BreakStatement.new
    end

    private def parse_continue_statement
      consume_token TokenType::CONTINUE
      consume_token TokenType::SEMICOLON
      ContinueStatement.new
    end

    private def parse_body
      consume_token TokenType::L_BRACE
      statements = [] of Statement
      while current_token.type != TokenType::R_BRACE
        statements << parse_statement
      end
      consume_token TokenType::R_BRACE
      statements
    end

    private def parse_params
      consume_token TokenType::L_PAREN
      params = [] of Token
      while current_token.type != TokenType::R_PAREN
        params << consume_token TokenType::IDENTIFIER
        if current_token.type == TokenType::R_PAREN
          break
        end
        consume_token TokenType::COMMA
      end
      consume_token TokenType::R_PAREN
      params.map { |param| param.lexeme }
    end

    private def parse_expr
      parse_expr_or
    end

    private def parse_expr_or
      expr = parse_expr_and
      while true
        if current_token.type == TokenType::OP_OR
          consume_token TokenType::OP_OR
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
        if current_token.type == TokenType::OP_AND
          consume_token TokenType::OP_AND
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
        case current_token.type
        when TokenType::OP_EQ
          consume_token TokenType::OP_EQ
          expr = BinaryExprEq.new expr, parse_expr_compare
        when TokenType::OP_NEQ
          consume_token TokenType::OP_NEQ
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
        case current_token.type
        when TokenType::OP_GT
          consume_token TokenType::OP_GT
          expr = BinaryExprGt.new expr, parse_expr_concat
        when TokenType::OP_LT
          consume_token TokenType::OP_LT
          expr = BinaryExprLt.new expr, parse_expr_concat
        when TokenType::OP_GE
          consume_token TokenType::OP_GE
          expr = BinaryExprGe.new expr, parse_expr_concat
        when TokenType::OP_LE
          consume_token TokenType::OP_LE
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
        if current_token.type == TokenType::OP_CONCAT
          consume_token TokenType::OP_CONCAT
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
        case current_token.type
        when TokenType::OP_PLUS
          consume_token TokenType::OP_PLUS
          expr = BinaryExprPlus.new expr, parse_expr_div_inv
        when TokenType::OP_MINUS
          consume_token TokenType::OP_MINUS
          expr = BinaryExprMinus.new expr, parse_expr_div_inv
        else
          break
        end
      end
      expr
    end

    private def parse_expr_div_inv
      expr = parse_expr_times_div_mod
      if current_token.type == TokenType::OP_DIV_INV
        consume_token TokenType::OP_DIV_INV
        BinaryExprDivInv.new expr, parse_expr_div_inv
      else
        expr
      end
    end

    private def parse_expr_times_div_mod
      expr = parse_expr_expt
      while true
        case current_token.type
        when TokenType::OP_TIMES
          consume_token TokenType::OP_TIMES
          expr = BinaryExprMult.new expr, parse_expr_expt
        when TokenType::OP_DIV
          consume_token TokenType::OP_DIV
          expr = BinaryExprDiv.new expr, parse_expr_expt
        when TokenType::OP_MOD
          consume_token TokenType::OP_MOD
          expr = BinaryExprMod.new expr, parse_expr_expt
        else
          break
        end
      end
      expr
    end

    private def parse_expr_expt
      expr = parse_expr_unary
      if current_token.type == TokenType::OP_EXPT
        consume_token TokenType::OP_EXPT
        BinaryExprExpt.new expr, parse_expr_expt
      else
        expr
      end
    end

    private def parse_expr_unary
      case current_token.type
      when TokenType::OP_MINUS
        consume_token TokenType::OP_MINUS
        UnaryExprMinus.new parse_expr_unary
      when TokenType::OP_NEG
        consume_token TokenType::OP_NEG
        UnaryExprNegation.new parse_expr_unary
      when TokenType::OP_TO_STR
        consume_token TokenType::OP_TO_STR
        UnaryExprToString.new parse_expr_unary
      when TokenType::OP_TO_NUM
        consume_token TokenType::OP_TO_NUM
        UnaryExprToNumber.new parse_expr_unary
      else
        parse_expr_call_access
      end
    end

    private def parse_expr_call_access
      expr = parse_expr_basic
      while true
        case current_token.type
        when TokenType::DOT
          consume_token TokenType::DOT
          identifier = consume_token TokenType::IDENTIFIER
          expr = ObjectAccessExpr.new expr, identifier.lexeme
        when TokenType::L_PAREN
          consume_token TokenType::L_PAREN
          args = [] of Expr
          while current_token.type != TokenType::R_PAREN
            args << parse_expr
            if current_token.type == TokenType::R_PAREN
              break
            end
            consume_token TokenType::COMMA
          end
          consume_token TokenType::R_PAREN
          expr = FunctionCallExpr.new expr, args
        else
          break
        end
      end
      expr
    end

    private def parse_expr_basic
      case current_token.type
      when TokenType::L_PAREN
        consume_token TokenType::L_PAREN
        expr = parse_expr
        consume_token TokenType::R_PAREN
        expr
      when TokenType::IDENTIFIER
        token = consume_token TokenType::IDENTIFIER
        VariableExpr.new token.lexeme
      when TokenType::NUMBER
        token = consume_token TokenType::NUMBER
        case token.lexeme[0..1]
        when "0x"
          NumberLiteralExpr.new token.lexeme[2..].to_i(16).to_f
        when "0b"
          NumberLiteralExpr.new token.lexeme[2..].to_i(2).to_f
        else
          NumberLiteralExpr.new token.lexeme.to_f
        end
      when TokenType::TRUE
        consume_token TokenType::TRUE
        BooleanLiteralExpr.new true
      when TokenType::FALSE
        consume_token TokenType::FALSE
        BooleanLiteralExpr.new false
      when TokenType::NULL
        consume_token TokenType::NULL
        NullLiteralExpr.new
      when TokenType::QUOTE
        parse_string
      else
        raise SyntaxError.new "Unexpected token #{current_token.type}: #{current_token.lexeme} "
      end
    end

    private def parse_string
      consume_token TokenType::QUOTE
      fragments = [] of StringFragment
      while current_token.type != TokenType::QUOTE
        case current_token.type
        when TokenType::STRING_FRAGMENT
          token = consume_token TokenType::STRING_FRAGMENT
          fragments << StringLiteralFragment.new token.lexeme
        when TokenType::L_BRACE
          consume_token TokenType::L_BRACE
          fragments << StringInterpolationFragment.new parse_expr
          consume_token TokenType::R_BRACE
        else
          raise SyntaxError.new "Unexpected token #{current_token.type}: #{current_token.lexeme} "
        end
      end
      consume_token TokenType::QUOTE
      StringLiteralExpr.new fragments
    end

    private def eof
      return @index >= @tokens.size
    end

    private def current_token
      return @tokens[@index]
    end

    private def consume_token(tt : TokenType)
      if eof
        raise SyntaxError.new "Unexpected end of input, expected #{tt}"
      elsif @tokens[@index].type == tt
        @index += 1
        return @tokens[@index - 1]
      else
        raise SyntaxError.new "Unexpected token #{current_token.type}: #{current_token.lexeme}, expected #{tt}"
      end
    end
  end
end
