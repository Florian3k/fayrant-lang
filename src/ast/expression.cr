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

      abstract class UnaryExpr < Expr
        getter expr
  
        def initialize(@expr : Expr)
        end
      end
  
      class UnaryExprMinus < UnaryExpr
        def initialize(expr : Expr)
          super
        end
  
        def eval(env) : NumberValue
          NumberValue.new -@expr.eval(env).getNumber
        end
  
        def ==(other : UnaryExprMinus)
          expr == other.expr
        end
      end

      class UnaryExprNegation < UnaryExpr
        def initialize(expr : Expr)
          super
        end
  
        def eval(env) : Boolean
          BooleanValue.new !@expr.eval(env).getBoolean
        end
  
        def ==(other : UnaryExprNegation)
          expr == other.expr
        end
      end

      class UnaryExprToString < UnaryExpr
        def initialize(expr : Expr)
          super
        end
  
        def eval(env) : AnyValue
          StringValue.new @expr.eval(env).toString
        end
  
        def ==(other : UnaryExprToString)
          expr == other.expr
        end
      end

      class UnaryExprToNumber < UnaryExpr
        def initialize(expr : Expr)
          super
        end
  
        def eval(env) : AnyValue
          NumberValue.new @expr.eval(env).ToNumber
        end
  
        def ==(other : UnaryExprToString)
          expr == other.expr
        end
      end

      # TODO: (UnaryExprToNumber)     Any -> Number (Any means bool, number or string in this context)

      

  end
end
