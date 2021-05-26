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

        def eval(env) : NumberValue
          case @expr.eval(env).type
          when ValueType::Number
            NumberValue.new @expr.eval(env).getNumber
          when ValueType::Boolean
            NumberValue.new @expr.eval(env).getBoolean ? 1 : 0
          when ValueType::String
            val = @expr.eval(env).getString.to_f64?
            unless val == Nil
              @expr.eval(env).getString.to_f64
            else
              raise Exception
            end
          else
            raise Exception
          end
        end

        def ==(other : UnaryExprToString)
          expr == other.expr
        end
      end

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

      class BinaryExprMult < BinaryExpr
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

      class BinaryExprDiv < BinaryExpr
        def initialize(lhs : Expr, rhs : Expr)
          super
        end
  
        def eval(env) : NumberValue
          unless @rhs.eval(env).getNumber == 0
            NumberValue.new @lhs.eval(env).getNumber / @rhs.eval(env).getNumber
          else
            raise Exception
          end
        end
  
        def ==(other : BinaryExprPlus)
          lhs == other.lhs && rhs == other.rhs
        end
      end

      class BinaryExprDivInv < BinaryExpr
        def initialize(lhs : Expr, rhs : Expr)
          super
        end
  
        def eval(env) : NumberValue
          unless @lhs.eval(env).getNumber == 0
            NumberValue.new @rhs.eval(env).getNumber / @lhs.eval(env).getNumber
          else
            raise Exception
          end
        end
  
        def ==(other : BinaryExprPlus)
          lhs == other.lhs && rhs == other.rhs
        end
      end

      class BinaryExprMod < BinaryExpr
        def initialize(lhs : Expr, rhs : Expr)
          super
        end
  
        def eval(env) : NumberValue
          unless @rhs.eval(env).getNumber == 0
            NumberValue.new @lhs.eval(env).getNumber % @rhs.eval(env).getNumber 
          else
            raise Exception
          end
        end
  
        def ==(other : BinaryExprPlus)
          lhs == other.lhs && rhs == other.rhs
        end
      end
      
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

    # TODO: Decide if we want bitwise operations
    #   &  (And)      Number x Number  -> Number
    #   |  (Or)      Boolean x Boolean -> Boolean

    class BinaryExprGt < BinaryExpr
      def initialize(lhs : Expr, rhs : Expr)
        super
      end

      def eval(env) : BooleanValue
        BooleanValue.new @lhs.eval(env).getNumber > @rhs.eval(env).getNumber
      end

      def ==(other : BinaryExprPlus)
        lhs == other.lhs && rhs == other.rhs
      end
    end

    class BinaryExprLt < BinaryExpr
      def initialize(lhs : Expr, rhs : Expr)
        super
      end

      def eval(env) : BooleanValue
        BooleanValue.new @lhs.eval(env).getNumber < @rhs.eval(env).getNumber
      end

      def ==(other : BinaryExprPlus)
        lhs == other.lhs && rhs == other.rhs
      end
    end

    class BinaryExprGe < BinaryExpr
      def initialize(lhs : Expr, rhs : Expr)
        super
      end

      def eval(env) : BooleanValue
        BooleanValue.new @lhs.eval(env).getNumber >= @rhs.eval(env).getNumber
      end

      def ==(other : BinaryExprPlus)
        lhs == other.lhs && rhs == other.rhs
      end
    end

    class BinaryExprLe < BinaryExpr
      def initialize(lhs : Expr, rhs : Expr)
        super
      end

      def eval(env) : BooleanValue
        BooleanValue.new @lhs.eval(env).getNumber <= @rhs.eval(env).getNumber
      end

      def ==(other : BinaryExprPlus)
        lhs == other.lhs && rhs == other.rhs
      end
    end

    class BinaryExprEq < BinaryExpr
      def initialize(lhs : Expr, rhs : Expr)
        super
      end

      def eval(env) : BooleanValue
        BooleanValue.new @lhs.eval(env).getNumber == @rhs.eval(env).getNumber
      end

      def ==(other : BinaryExprPlus)
        lhs == other.lhs && rhs == other.rhs
      end
    end

    class BinaryExprNeq < BinaryExpr
      def initialize(lhs : Expr, rhs : Expr)
        super
      end

      def eval(env) : BooleanValue
        BooleanValue.new @lhs.eval(env).getNumber != @rhs.eval(env).getNumber
      end

      def ==(other : BinaryExprPlus)
        lhs == other.lhs && rhs == other.rhs
      end
    end

    class BinaryExprConcat < BinaryExpr
      def initialize(lhs : Expr, rhs : Expr)
        super
      end

      def eval(env) : StringValue
        StringValue.new @lhs.eval(env).toString + @rhs.eval(env).toString
      end

      def ==(other : BinaryExprPlus)
        lhs == other.lhs && rhs == other.rhs
      end
    end

    # VALIDATE THE CODE AND WRITE TESTS!

  end
end
