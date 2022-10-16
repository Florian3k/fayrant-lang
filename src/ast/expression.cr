require "../value.cr"

module PwoPlusPlus
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

      def eval(ctx : Context) : F64Value
        F64Value.new @value
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

    class StringLiteralExpr < Expr
      getter fragments

      def initialize(@fragments : Array(StringFragment))
      end

      def eval(ctx : Context) : AnyValue
        StringValue.new fragments.join("") { |frag| frag.eval(ctx) }
      end

      def ==(other : StringLiteralExpr)
        fragments == other.fragments
      end
    end

    abstract class StringFragment
      abstract def eval(ctx : Context) : String

      def ==(other)
        false
      end
    end

    class StringLiteralFragment < StringFragment
      getter str

      def initialize(@str : String)
      end

      def eval(ctx : Context) : String
        str
      end

      def ==(other : StringLiteralFragment)
        str == other.str
      end
    end

    class StringInterpolationFragment < StringFragment
      getter expr

      def initialize(@expr : Expr)
      end

      def eval(ctx : Context) : String
        UnaryExprToString.new(expr).eval(ctx).get_string
      end

      def ==(other : StringInterpolationFragment)
        expr == other.expr
      end
    end

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

      def eval(ctx : Context) : AnyValue
        val = @expr.eval(ctx)
        case val.type
        when ValueType::I32
          I32Value.new -val.get_i32
        when ValueType::I64
          I64Value.new -val.get_i64
        when ValueType::F32
          F32Value.new -val.get_f32
        when ValueType::F64
          F64Value.new -val.get_f64
        else
          NullValue.new
        end
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
        BooleanValue.new !@expr.eval(ctx).get_boolean
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
        StringValue.new @expr.eval(ctx).to_string
      end

      def ==(other : UnaryExprToString)
        expr == other.expr
      end
    end

    class UnaryExprToNumber < UnaryExpr
      def initialize(expr : Expr)
        super
      end

      def eval(ctx : Context) : AnyValue
        val = @expr.eval(ctx)
        case val.type
        # when ValueType::Number
        #   NumberValue.new val.get_number
        when ValueType::Boolean
          F64Value.new val.get_boolean ? 1.0 : 0.0
        when ValueType::String
          val = val.get_string.to_f64?
          if val.is_a?(Float64)
            F64Value.new val
          else
            NullValue.new
          end
        else
          NullValue.new
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

      def eval(ctx : Context) : AnyValue
        val = @lhs.eval(ctx)
        rval = @rhs.eval(ctx)
        case val.type
        when ValueType::I32
          I32Value.new val.get_i32 + rval.get_i32
        when ValueType::I64
          I64Value.new val.get_i64 + rval.get_i64
        when ValueType::F32
          F32Value.new val.get_f32 + rval.get_f32
        when ValueType::F64
          F64Value.new val.get_f64 + rval.get_f64
        else
          NullValue.new
        end
      end

      def ==(other : BinaryExprPlus)
        lhs == other.lhs && rhs == other.rhs
      end
    end

    class BinaryExprMinus < BinaryExpr
      def initialize(lhs : Expr, rhs : Expr)
        super
      end

      def eval(ctx : Context) : AnyValue
        val = @lhs.eval(ctx)
        rval = @rhs.eval(ctx)
        case val.type
        when ValueType::I32
          I32Value.new val.get_i32 - rval.get_i32
        when ValueType::I64
          I64Value.new val.get_i64 - rval.get_i64
        when ValueType::F32
          F32Value.new val.get_f32 - rval.get_f32
        when ValueType::F64
          F64Value.new val.get_f64 - rval.get_f64
        else
          NullValue.new
        end
      end

      def ==(other : BinaryExprMinus)
        lhs == other.lhs && rhs == other.rhs
      end
    end

    class BinaryExprMult < BinaryExpr
      def initialize(lhs : Expr, rhs : Expr)
        super
      end

      def eval(ctx : Context) : AnyValue
        val = @lhs.eval(ctx)
        rval = @rhs.eval(ctx)
        case val.type
        when ValueType::I32
          I32Value.new val.get_i32 * rval.get_i32
        when ValueType::I64
          I64Value.new val.get_i64 * rval.get_i64
        when ValueType::F32
          F32Value.new val.get_f32 * rval.get_f32
        when ValueType::F64
          F64Value.new val.get_f64 * rval.get_f64
        else
          NullValue.new
        end
      end

      def ==(other : BinaryExprMult)
        lhs == other.lhs && rhs == other.rhs
      end
    end

    class BinaryExprDiv < BinaryExpr
      def initialize(lhs : Expr, rhs : Expr)
        super
      end

      def eval(ctx : Context) : AnyValue
        val = @lhs.eval(ctx)
        rval = @rhs.eval(ctx)
        case val.type
        when ValueType::I32
          I32Value.new (val.get_i32 / rval.get_i32).to_i32
        when ValueType::I64
          I64Value.new (val.get_i64 / rval.get_i64).to_i64
        when ValueType::F32
          F32Value.new val.get_f32 / rval.get_f32
        when ValueType::F64
          F64Value.new val.get_f64 / rval.get_f64
        else
          NullValue.new
        end

        # rval = @rhs.eval(ctx).get_number
        # unless rval == 0
        #   NumberValue.new @lhs.eval(ctx).get_number / rval
        # else
        #   raise ArithmeticError.new "Division by 0"
        # end
      end

      def ==(other : BinaryExprDiv)
        lhs == other.lhs && rhs == other.rhs
      end
    end

    class BinaryExprDivInv < BinaryExpr
      def initialize(lhs : Expr, rhs : Expr)
        super
      end

      def eval(ctx : Context) : AnyValue
        val = @lhs.eval(ctx)
        rval = @rhs.eval(ctx)
        case val.type
        when ValueType::I32
          I32Value.new (rval.get_i32 / val.get_i32).to_i32
        when ValueType::I64
          I64Value.new (rval.get_i64 / val.get_i64).to_i64
        when ValueType::F32
          F32Value.new rval.get_f32 / val.get_f32
        when ValueType::F64
          F64Value.new rval.get_f64 / val.get_f64
        else
          NullValue.new
        end

        # lval = @lhs.eval(ctx).get_number
        # unless lval == 0
        #   NumberValue.new @rhs.eval(ctx).get_number / lval
        # else
        #   raise ArithmeticError.new "Division by 0"
        # end
      end

      def ==(other : BinaryExprDivInv)
        lhs == other.lhs && rhs == other.rhs
      end
    end

    class BinaryExprMod < BinaryExpr
      def initialize(lhs : Expr, rhs : Expr)
        super
      end

      def eval(ctx : Context) : AnyValue
        val = @lhs.eval(ctx)
        rval = @rhs.eval(ctx)
        case val.type
        when ValueType::I32
          I32Value.new val.get_i32 % rval.get_i32
        when ValueType::I64
          I64Value.new val.get_i64 % rval.get_i64
        when ValueType::F32
          F32Value.new val.get_f32 % rval.get_f32
        when ValueType::F64
          F64Value.new val.get_f64 % rval.get_f64
        else
          NullValue.new
        end

        # rval = @rhs.eval(ctx).get_number
        # unless rval == 0
        #   NumberValue.new @lhs.eval(ctx).get_number % rval
        # else
        #   raise ArithmeticError.new "Division by 0"
        # end
      end

      def ==(other : BinaryExprMod)
        lhs == other.lhs && rhs == other.rhs
      end
    end

    class BinaryExprExpt < BinaryExpr
      def initialize(lhs : Expr, rhs : Expr)
        super
      end

      def eval(ctx : Context) : AnyValue
        val = @lhs.eval(ctx)
        rval = @rhs.eval(ctx)
        case val.type
        when ValueType::I32
          I32Value.new val.get_i32 ** rval.get_i32
        when ValueType::I64
          I64Value.new val.get_i64 ** rval.get_i64
        when ValueType::F32
          F32Value.new val.get_f32 ** rval.get_f32
        when ValueType::F64
          F64Value.new val.get_f64 ** rval.get_f64
        else
          NullValue.new
        end

        # TODO check for exceptions
        # NumberValue.new @lhs.eval(ctx).get_number ** @rhs.eval(ctx).get_number
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
        BooleanValue.new @lhs.eval(ctx).get_boolean && @rhs.eval(ctx).get_boolean
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
        BooleanValue.new @lhs.eval(ctx).get_boolean || @rhs.eval(ctx).get_boolean
      end

      def ==(other : BinaryExprOr)
        lhs == other.lhs && rhs == other.rhs
      end
    end

    class BinaryExprGt < BinaryExpr
      def initialize(lhs : Expr, rhs : Expr)
        super
      end

      def eval(ctx : Context) : AnyValue
        val = @lhs.eval(ctx)
        rval = @rhs.eval(ctx)
        case val.type
        when ValueType::I32
          BooleanValue.new val.get_i32 > rval.get_i32
        when ValueType::I64
          BooleanValue.new val.get_i64 > rval.get_i64
        when ValueType::F32
          BooleanValue.new val.get_f32 > rval.get_f32
        when ValueType::F64
          BooleanValue.new val.get_f64 > rval.get_f64
        else
          NullValue.new
        end

        # BooleanValue.new @lhs.eval(ctx).get_number > @rhs.eval(ctx).get_number
      end

      def ==(other : BinaryExprGt)
        lhs == other.lhs && rhs == other.rhs
      end
    end

    class BinaryExprLt < BinaryExpr
      def initialize(lhs : Expr, rhs : Expr)
        super
      end

      def eval(ctx : Context) : AnyValue
        val = @lhs.eval(ctx)
        rval = @rhs.eval(ctx)
        case val.type
        when ValueType::I32
          BooleanValue.new val.get_i32 < rval.get_i32
        when ValueType::I64
          BooleanValue.new val.get_i64 < rval.get_i64
        when ValueType::F32
          BooleanValue.new val.get_f32 < rval.get_f32
        when ValueType::F64
          BooleanValue.new val.get_f64 < rval.get_f64
        else
          NullValue.new
        end

        # BooleanValue.new @lhs.eval(ctx).get_number < @rhs.eval(ctx).get_number
      end

      def ==(other : BinaryExprLt)
        lhs == other.lhs && rhs == other.rhs
      end
    end

    class BinaryExprGe < BinaryExpr
      def initialize(lhs : Expr, rhs : Expr)
        super
      end

      def eval(ctx : Context) : AnyValue
        val = @lhs.eval(ctx)
        rval = @rhs.eval(ctx)
        case val.type
        when ValueType::I32
          BooleanValue.new val.get_i32 >= rval.get_i32
        when ValueType::I64
          BooleanValue.new val.get_i64 >= rval.get_i64
        when ValueType::F32
          BooleanValue.new val.get_f32 >= rval.get_f32
        when ValueType::F64
          BooleanValue.new val.get_f64 >= rval.get_f64
        else
          NullValue.new
        end

        # BooleanValue.new @lhs.eval(ctx).get_number >= @rhs.eval(ctx).get_number
      end

      def ==(other : BinaryExprGe)
        lhs == other.lhs && rhs == other.rhs
      end
    end

    class BinaryExprLe < BinaryExpr
      def initialize(lhs : Expr, rhs : Expr)
        super
      end

      def eval(ctx : Context) : AnyValue
        val = @lhs.eval(ctx)
        rval = @rhs.eval(ctx)
        case val.type
        when ValueType::I32
          BooleanValue.new val.get_i32 <= rval.get_i32
        when ValueType::I64
          BooleanValue.new val.get_i64 <= rval.get_i64
        when ValueType::F32
          BooleanValue.new val.get_f32 <= rval.get_f32
        when ValueType::F64
          BooleanValue.new val.get_f64 <= rval.get_f64
        else
          NullValue.new
        end

        # BooleanValue.new @lhs.eval(ctx).get_number <= @rhs.eval(ctx).get_number
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
        StringValue.new @lhs.eval(ctx).to_string + @rhs.eval(ctx).to_string
      end

      def ==(other : BinaryExprConcat)
        lhs == other.lhs && rhs == other.rhs
      end
    end

    class FunctionCallExpr < Expr
      getter fn
      getter arhs

      def initialize(@fn : Expr, @arhs : Array(Expr))
      end

      def eval(ctx : Context) : AnyValue
        fn.eval(ctx).get_function.call(arhs.map { |expr| expr.eval(ctx) })
      end

      def ==(other : FunctionCallExpr)
        fn == other.fn && arhs == other.arhs
      end
    end

    class ObjectAccessExpr < Expr
      getter obj
      getter field

      def initialize(@obj : Expr, @field : String)
      end

      def eval(ctx : Context) : AnyValue
        obj.eval(ctx).get_object.get_field(field)
      end

      def ==(other : ObjectAccessExpr)
        obj == other.obj && field == other.field
      end
    end
  end
end
