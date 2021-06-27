require "./expression.cr"

module FayrantLang
  module AST
    abstract class Statement
      def ==(other)
        false
      end
    end

    class ExprStatement < Statement
      getter expr

      def initialize(@expr : Expr)
      end

      def ==(other : ExprStatement)
        expr == other.expr
      end
    end
  end
end
