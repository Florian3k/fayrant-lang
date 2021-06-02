require "./expression.cr"

module FayrantLang
  module AST
    abstract class Statement
    end

    class ExprStatement < Statement
      getter expr

      def initialize(@expr : Expr)
      end
    end
  end
end
