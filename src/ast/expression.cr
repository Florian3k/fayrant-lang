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

    class BooleanLiteralExpr < LiteralExpr(Bool)
        def initialize(value : Bool)
          super
        end
  
        def eval(env) : BooleanValue
          BooleanValue.new @value
        end
      end

      class NumberLiteralExpr < LiteralExpr(Float64)
        def initialize(value : Float64)
          super
        end
  
        def eval(env) : NumberValue
          NumberValue.new @value
        end
      end

      class NullLiteralExpr < LiteralExpr(Nil)
        def initialize(value : Nil = nil)
          super
        end
  
        def eval(env) : NullValue
          NullValue.new
        end
      end


      # TODO : Implement string literals 
  end
end
