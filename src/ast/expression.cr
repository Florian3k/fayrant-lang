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

      # ?????
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

      abstract class BinaryExpr < Expr
        getter lhs
        getter rhs
  
        def initialize(@lhs : Expr, @rhs : Expr)
        end
      end
  
      class BinaryExprPlus < BinaryExpr
        def initialize(lhs : Expr, rhs : Expr)
          super
        end
  
        def eval(env) : NumberValue
          NumberValue.new @lhs.eval(env).getNumber + @rhs.eval(env).getNumber
        end
  
        def ==(other : BinaryExprPlus)
          lhs == other.lhs && rhs == other.rhs
        end
      end

      class BinaryExprMinus < BinaryExpr
        def initialize(lhs : Expr, rhs : Expr)
          super
        end
  
        def eval(env) : NumberValue
          NumberValue.new @lhs.eval(env).getNumber - @rhs.eval(env).getNumber
        end
  
        def ==(other : BinaryExprPlus)
          lhs == other.lhs && rhs == other.rhs
        end
      end

      class BinaryExprTimes < BinaryExpr
        def initialize(lhs : Expr, rhs : Expr)
          super
        end
  
        def eval(env) : NumberValue
          NumberValue.new @lhs.eval(env).getNumber * @rhs.eval(env).getNumber
        end
  
        def ==(other : BinaryExprPlus)
          lhs == other.lhs && rhs == other.rhs
        end
      end

      # TODO: Make sure we have a consistent view on handling arithmetic expressions and implement div and mod:

    #   /  (Div)      Number x Number  -> Number
    #   \  (DivInv)   Number x Number  -> Number
    #   %  (Mod)      Number x Number  -> Number

    class BinaryExprExpt < BinaryExpr
      def initialize(lhs : Expr, rhs : Expr)
        super
      end

      def eval(env) : NumberValue
        NumberValue.new @lhs.eval(env).getNumber ** @rhs.eval(env).getNumber
      end

      def ==(other : BinaryExprPlus)
        lhs == other.lhs && rhs == other.rhs
      end
    end

    #   &  (And)      Number x Number  -> Number
    #   |  (Or)      Boolean x Boolean -> Boolean
    #   >  (Gt)       Number x Number  -> Boolean
    #   <  (Lt)       Number x Number  -> Boolean
    #   <= (Le)       Number x Number  -> Boolean
    #   >= (Ge)       Number x Number  -> Boolean
    #   == (Eq)          Any x Any     -> Boolean (compare values using ==)
    #   != (Neq)         Any x Any     -> Boolean (as above)
    #   ++ (Concat)   String x String  -> String

  end
end
