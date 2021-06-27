require "../value.cr"

module FayrantLang
  module AST
    abstract class Expr
      abstract def eval(ctx : Context) : AnyValue

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

      def eval(ctx : Context) : BooleanValue
        BooleanValue.new @value
      end
    end

    class NumberLiteralExpr < LiteralExpr(Float64)
      def initialize(value : Float64)
        super
      end

      def eval(ctx : Context) : NumberValue
        NumberValue.new @value
      end
    end

    class NullLiteralExpr < LiteralExpr(Nil)
      def initialize(value : Nil = nil)
        super
      end

      def eval(ctx : Context) : NullValue
        NullValue.new
      end
    end

    # TODO : Implement string literals

    class VariableExpr < Expr
      getter name

      def initialize(@name : String)
      end

      def eval(ctx : Context) : AnyValue
        ctx.get_var(name)
      end

      def ==(other : VariableExpr)
        name == other.name
      end
    end

    abstract class UnaryExpr < Expr
      getter expr

      def initialize(@expr : Expr)
      end
    end

    class UnaryExprMinus < UnaryExpr
      def initialize(expr : Expr)
        super
      end

      def eval(ctx : Context) : NumberValue
        NumberValue.new -@expr.eval(ctx).getNumber
      end

      def ==(other : UnaryExprMinus)
        expr == other.expr
      end
    end

    class UnaryExprNegation < UnaryExpr
      def initialize(expr : Expr)
        super
      end

      def eval(ctx : Context) : BooleanValue
        BooleanValue.new !@expr.eval(ctx).getBoolean
      end

      def ==(other : UnaryExprNegation)
        expr == other.expr
      end
    end

    class UnaryExprToString < UnaryExpr
      def initialize(expr : Expr)
        super
      end

      def eval(ctx : Context) : AnyValue
        StringValue.new @expr.eval(ctx).toString
      end

      def ==(other : UnaryExprToString)
        expr == other.expr
      end
    end

    class UnaryExprToNumber < UnaryExpr
      def initialize(expr : Expr)
        super
      end

      def eval(ctx : Context) : NumberValue
        val = @expr.eval(ctx)
        case val.type
        when ValueType::Number
          NumberValue.new val.getNumber
        when ValueType::Boolean
          NumberValue.new val.getBoolean ? 1.0 : 0.0
        when ValueType::String
          val = val.getString.to_f64?
          if val.is_a?(Float64)
            NumberValue.new val
          else
            # TODO
            raise Exception.new "TODO"
          end
        else
          # TODO
          raise Exception.new "TODO"
        end
      end

      def ==(other : UnaryExprToNumber)
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

      def eval(ctx : Context) : NumberValue
        NumberValue.new @lhs.eval(ctx).getNumber + @rhs.eval(ctx).getNumber
      end

      def ==(other : BinaryExprPlus)
        lhs == other.lhs && rhs == other.rhs
      end
    end

    class BinaryExprMinus < BinaryExpr
      def initialize(lhs : Expr, rhs : Expr)
        super
      end

      def eval(ctx : Context) : NumberValue
        NumberValue.new @lhs.eval(ctx).getNumber - @rhs.eval(ctx).getNumber
      end

      def ==(other : BinaryExprMinus)
        lhs == other.lhs && rhs == other.rhs
      end
    end

    class BinaryExprMult < BinaryExpr
      def initialize(lhs : Expr, rhs : Expr)
        super
      end

      def eval(ctx : Context) : NumberValue
        NumberValue.new @lhs.eval(ctx).getNumber * @rhs.eval(ctx).getNumber
      end

      def ==(other : BinaryExprMult)
        lhs == other.lhs && rhs == other.rhs
      end
    end

    class BinaryExprDiv < BinaryExpr
      def initialize(lhs : Expr, rhs : Expr)
        super
      end

      def eval(ctx : Context) : NumberValue
        rval = @rhs.eval(ctx).getNumber
        unless rval == 0
          NumberValue.new @lhs.eval(ctx).getNumber / rval
        else
          # TODO
          raise Exception.new "TODO"
        end
      end

      def ==(other : BinaryExprDiv)
        lhs == other.lhs && rhs == other.rhs
      end
    end

    class BinaryExprDivInv < BinaryExpr
      def initialize(lhs : Expr, rhs : Expr)
        super
      end

      def eval(ctx : Context) : NumberValue
        lval = @lhs.eval(ctx).getNumber
        unless lval == 0
          NumberValue.new @rhs.eval(ctx).getNumber / lval
        else
          # TODO
          raise Exception.new "TODO"
        end
      end

      def ==(other : BinaryExprDivInv)
        lhs == other.lhs && rhs == other.rhs
      end
    end

    class BinaryExprMod < BinaryExpr
      def initialize(lhs : Expr, rhs : Expr)
        super
      end

      def eval(ctx : Context) : NumberValue
        rval = @rhs.eval(ctx).getNumber
        unless rval == 0
          NumberValue.new @lhs.eval(ctx).getNumber % rval
        else
          raise Exception.new "TODO"
        end
      end

      def ==(other : BinaryExprMod)
        lhs == other.lhs && rhs == other.rhs
      end
    end

    class BinaryExprExpt < BinaryExpr
      def initialize(lhs : Expr, rhs : Expr)
        super
      end

      def eval(ctx : Context) : NumberValue
        # TODO check for exceptions
        NumberValue.new @lhs.eval(ctx).getNumber ** @rhs.eval(ctx).getNumber
      end

      def ==(other : BinaryExprExpt)
        lhs == other.lhs && rhs == other.rhs
      end
    end

    class BinaryExprAnd < BinaryExpr
      def initialize(lhs : Expr, rhs : Expr)
        super
      end

      def eval(ctx : Context) : BooleanValue
        BooleanValue.new @lhs.eval(ctx).getBoolean && @rhs.eval(ctx).getBoolean
      end

      def ==(other : BinaryExprAnd)
        lhs == other.lhs && rhs == other.rhs
      end
    end

    class BinaryExprOr < BinaryExpr
      def initialize(lhs : Expr, rhs : Expr)
        super
      end

      def eval(ctx : Context) : BooleanValue
        BooleanValue.new @lhs.eval(ctx).getBoolean || @rhs.eval(ctx).getBoolean
      end

      def ==(other : BinaryExprOr)
        lhs == other.lhs && rhs == other.rhs
      end
    end

    class BinaryExprGt < BinaryExpr
      def initialize(lhs : Expr, rhs : Expr)
        super
      end

      def eval(ctx : Context) : BooleanValue
        BooleanValue.new @lhs.eval(ctx).getNumber > @rhs.eval(ctx).getNumber
      end

      def ==(other : BinaryExprGt)
        lhs == other.lhs && rhs == other.rhs
      end
    end

    class BinaryExprLt < BinaryExpr
      def initialize(lhs : Expr, rhs : Expr)
        super
      end

      def eval(ctx : Context) : BooleanValue
        BooleanValue.new @lhs.eval(ctx).getNumber < @rhs.eval(ctx).getNumber
      end

      def ==(other : BinaryExprLt)
        lhs == other.lhs && rhs == other.rhs
      end
    end

    class BinaryExprGe < BinaryExpr
      def initialize(lhs : Expr, rhs : Expr)
        super
      end

      def eval(ctx : Context) : BooleanValue
        BooleanValue.new @lhs.eval(ctx).getNumber >= @rhs.eval(ctx).getNumber
      end

      def ==(other : BinaryExprGe)
        lhs == other.lhs && rhs == other.rhs
      end
    end

    class BinaryExprLe < BinaryExpr
      def initialize(lhs : Expr, rhs : Expr)
        super
      end

      def eval(ctx : Context) : BooleanValue
        BooleanValue.new @lhs.eval(ctx).getNumber <= @rhs.eval(ctx).getNumber
      end

      def ==(other : BinaryExprLe)
        lhs == other.lhs && rhs == other.rhs
      end
    end

    class BinaryExprEq < BinaryExpr
      def initialize(lhs : Expr, rhs : Expr)
        super
      end

      def eval(ctx : Context) : BooleanValue
        BooleanValue.new @lhs.eval(ctx) == @rhs.eval(ctx)
      end

      def ==(other : BinaryExprEq)
        lhs == other.lhs && rhs == other.rhs
      end
    end

    class BinaryExprNeq < BinaryExpr
      def initialize(lhs : Expr, rhs : Expr)
        super
      end

      def eval(ctx : Context) : BooleanValue
        BooleanValue.new @lhs.eval(ctx) != @rhs.eval(ctx)
      end

      def ==(other : BinaryExprNeq)
        lhs == other.lhs && rhs == other.rhs
      end
    end

    class BinaryExprConcat < BinaryExpr
      def initialize(lhs : Expr, rhs : Expr)
        super
      end

      def eval(ctx : Context) : StringValue
        StringValue.new @lhs.eval(ctx).toString + @rhs.eval(ctx).toString
      end

      def ==(other : BinaryExprConcat)
        lhs == other.lhs && rhs == other.rhs
      end
    end

    # TODO: VALIDATE THE CODE AND WRITE TESTS!

    class FunctionCallExpr < Expr
      getter fn
      getter args

      def initialize(@fn : Expr, @args : Array(Expr))
      end

      def eval(ctx : Context) : AnyValue
        fn.eval(ctx).getFunction.call(args.map { |expr| expr.eval(ctx) })
      end

      def ==(other : FunctionCallExpr)
        fn == other.fn && args == other.args
      end
    end

    class ObjectAccessExpr < Expr
      getter obj
      getter field

      def initialize(@obj : Expr, @field : String)
      end

      def eval(ctx : Context) : AnyValue
        raise Exception.new "TODO"
      end

      def ==(other : ObjectAccessExpr)
        obj == other.obj && field == other.field
      end
    end
  end
end
