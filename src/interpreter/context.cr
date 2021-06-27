require "../value.cr"

module FayrantLang
  class Context
    def initialize(@parentContext : Context | Nil = nil)
      @vars = Hash(String, AnyValue).new
    end

    def get_var(name : String) : AnyValue
      if @vars.has_key?(name)
        @vars[name]
      elsif ctx = @parentContext
        ctx.get_var name
      else
        raise Exception.new "TODO - undefined variable #{name}"
      end
    end

    def set_var(name : String, value : AnyValue)
      if @vars.has_key?(name)
        @vars[name] = value
      elsif ctx = @parentContext
        ctx.set_var name, value
      else
        raise Exception.new "TODO - undefined variable #{name}"
      end
    end

    def create_var(name : String, value : AnyValue)
      if @vars.has_key?(name)
        raise Exception.new "TODO - #{name} variable already defined in current scope"
      else
        @vars[name] = value
      end
    end
  end
end
