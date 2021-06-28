require "./expression.cr"

module FayrantLang
  module AST
    enum ExecResult
      NONE
      RETURN
      BREAK
      CONTINUE
    end

    def none_result
      {ExecResult::NONE, NullValue.new}
    end

    def exec_body(body : Array(Statement), ctx : Context) : {ExecResult, AnyValue}
      init = none_result
      body.reduce init do |res, statement|
        res[0] == ExecResult::NONE ? statement.exec(ctx) : res
      end
    end

    abstract class Statement
      abstract def exec(ctx : Context) : {ExecResult, AnyValue}

      def ==(other)
        false
      end
    end

    class FunctionDeclarationStatement < Statement
      getter name
      getter params
      getter body

      def initialize(@name : String, @params : Array(String), @body : Array(Statement))
      end

      def exec(ctx : Context) : {ExecResult, AnyValue}
        fn = UserFunction.new params, body, ctx
        ctx.create_var(@name, fn)
        none_result
      end

      def ==(other : FunctionDeclarationStatement)
        name == other.name && params == other.params && body == other.body
      end
    end

    class ClassDeclarationStatement < Statement
      getter name
      getter ctor_params
      getter ctor_body
      getter methods

      def initialize(
        @name : String,
        @ctor_params : Array(String),
        @ctor_body : Array(Statement),
        @methods : Array(FunctionDeclarationStatement)
      )
      end

      def exec(ctx : Context) : {ExecResult, AnyValue}
        methods_hash = Hash(String, FunctionDeclarationStatement).new
        methods.each do |method|
          methods_hash[method.name] = method
        end
        class_fn = BuiltinFunction.new ctor_params.size do |args|
          obj_ctx = Context.new ctx
          obj = ObjectValue.new name, methods_hash, obj_ctx
          obj_ctx.create_var("this", obj)
          ctor = UserFunction.new ctor_params, ctor_body, obj_ctx
          ctor.call(args)
          obj
        end

        ctx.create_var name, class_fn
        none_result
      end

      def ==(other : ClassDeclarationStatement)
        name == other.name &&
          ctor_params == other.ctor_params &&
          ctor_body == other.ctor_body &&
          methods == other.methods
      end
    end

    class IfStatement < Statement
      getter cond
      getter true_body
      getter false_body

      def initialize(@cond : Expr, @true_body : Array(Statement), @false_body : Array(Statement))
      end

      def exec(ctx : Context) : {ExecResult, AnyValue}
        body =
          if cond.eval(ctx).get_boolean
            true_body
          else
            false_body
          end
        exec_body body, ctx
      end

      def ==(other : IfStatement)
        cond == other.cond && true_body == other.true_body && false_body == other.false_body
      end
    end

    class VariableDeclarationStatement < Statement
      getter name
      getter expr

      def initialize(@name : String, @expr : Expr)
      end

      def exec(ctx : Context) : {ExecResult, AnyValue}
        ctx.create_var(name, expr.eval(ctx))
        none_result
      end

      def ==(other : VariableDeclarationStatement)
        name == other.name && expr == other.expr
      end
    end

    class VariableAssignmentStatement < Statement
      getter name
      getter expr

      def initialize(@name : String, @expr : Expr)
      end

      def exec(ctx : Context) : {ExecResult, AnyValue}
        ctx.set_var(name, expr.eval(ctx))
        none_result
      end

      def ==(other : VariableAssignmentStatement)
        name == other.name && expr == other.expr
      end
    end

    class ObjectFieldAssignmentStatement < Statement
      getter obj_name
      getter field_name
      getter expr

      def initialize(@obj_name : String, @field_name : String, @expr : Expr)
      end

      def exec(ctx : Context) : {ExecResult, AnyValue}
        obj = ctx.get_var(obj_name).get_object
        obj.set_field(field_name, expr.eval(ctx))
        none_result
      end

      def ==(other : ObjectFieldAssignmentStatement)
        obj_name == other.obj_name && field_name == other.field_name && expr == other.expr
      end
    end

    class ReturnStatement < Statement
      getter expr

      def initialize(@expr : Expr)
      end

      def exec(ctx : Context) : {ExecResult, AnyValue}
        retval = expr.eval(ctx)
        {ExecResult::RETURN, retval}
      end

      def ==(other : ReturnStatement)
        expr == other.expr
      end
    end

    class ExprStatement < Statement
      getter expr

      def initialize(@expr : Expr)
      end

      def exec(ctx : Context) : {ExecResult, AnyValue}
        expr.eval(ctx)
        none_result
      end

      def ==(other : ExprStatement)
        expr == other.expr
      end
    end
  end
end
