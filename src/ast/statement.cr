require "./expression.cr"

module FayrantLang
  module AST
    enum ExecResult
      NONE
      RETURN
      BREAK
      CONTINUE
    end

    abstract class Statement
      abstract def exec(env : Object) : {ExecResult, AnyValue}

      def ==(other)
        false
      end
    end

    class VariableDeclarationStatement < Statement
      getter name
      getter expr

      def initialize(@name : String, @expr : Expr)
      end

      def exec(env : Object) : {ExecResult, AnyValue}
        # TODO
        raise Exception.new "TODO"
      end

      def ==(other : VariableDeclarationStatement)
        name == other.name && expr == other.expr
      end
    end

    class ExprStatement < Statement
      getter expr

      def initialize(@expr : Expr)
      end

      def exec(env : Object) : {ExecResult, AnyValue}
        expr.eval(ctx)
        return {ExecResult::NONE, NullValue.new}
      end

      def ==(other : ExprStatement)
        expr == other.expr
      end
    end
  end
end
