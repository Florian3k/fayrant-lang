require "./expression.cr"

module FayrantLang
  module AST
    enum ExecResult
      NONE
      RETURN
      BREAK
      CONTINUE
    end

    def exec_body(body : Array(Statement), ctx : Context) : {ExecResult, AnyValue}
      init = {ExecResult::NONE, NullValue.new}
      body.reduce init do |res, statement|
        res[0] == ExecResult::NONE ? statement.exec(ctx) : res
      end
    end

    abstract class Statement
      abstract def exec(ctx : Context) : {ExecResult, AnyValue}

      def ==(other)
        false
      end
    end

    class IfStatement < Statement
      getter cond
      getter true_body
      getter false_body

      def initialize(@cond : Expr, @true_body : Array(Statement), @false_body : Array(Statement))
      end

      def exec(ctx : Context) : {ExecResult, AnyValue}
        body =
          if cond.eval(ctx).getBoolean
            true_body
          else
            false_body
          end
        exec_body body, ctx
      end

      def ==(other : IfStatement)
        cond == other.cond && true_body == other.true_body && false_body == other.false_body
      end
    end

    class VariableDeclarationStatement < Statement
      getter name
      getter expr

      def initialize(@name : String, @expr : Expr)
      end

      def exec(ctx : Context) : {ExecResult, AnyValue}
        ctx.create_var(name, expr.eval(ctx))
        {ExecResult::NONE, NullValue.new}
      end

      def ==(other : VariableDeclarationStatement)
        name == other.name && expr == other.expr
      end
    end

    class ExprStatement < Statement
      getter expr

      def initialize(@expr : Expr)
      end

      def exec(ctx : Context) : {ExecResult, AnyValue}
        expr.eval(ctx)
        {ExecResult::NONE, NullValue.new}
      end

      def ==(other : ExprStatement)
        expr == other.expr
      end
    end
  end
end
