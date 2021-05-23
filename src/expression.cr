require "../value.cr"

module FayrantLang
  module AST
    abstract class Expr
      abstract def eval(env : Object) : AnyValue # TODO

      def ==(other)
        false
      end
    end

    abstract class LiteralExpr(T) < Expr
        getter value
  
        def initialize(@value : T)
        end
  
        def ==(other : LiteralExpr(T))
          value == other.value
        end
    end

    


  end
end
