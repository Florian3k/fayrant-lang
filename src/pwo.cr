require "./parser/lexer.cr"
require "./parser/parser.cr"
require "./interpreter/context.cr"

include PwoPlusPlus

def initial_context
  ctx = Context.new
  initial_vars = [
    {
      "print",
      BuiltinFunction.new 1 do |args|
        puts args[0].to_string
        NullValue.new
      end,
    },
    {
      "input",
      BuiltinFunction.new 0 do |args|
        str = gets
        if str.is_a?(Nil)
          raise Exception.new "Reading input failed"
        end
        StringValue.new str
      end,
    },
    {
      "Array",
      BuiltinFunction.new -1 do |args|
        ArrayObjectValue.new args
      end,
    },
    {
      "i32",
      BuiltinFunction.new 1 do |args|
        val = args[0]
        case val.type
        when ValueType::I32
          I32Value.new val.get_i32.to_i32
        when ValueType::I64
          I32Value.new val.get_i64.to_i32
        when ValueType::F32
          I32Value.new val.get_f32.to_i32
        when ValueType::F64
          I32Value.new val.get_f64.to_i32
        when ValueType::String
          I32Value.new val.get_string.to_i32
        else
          I32Value.new 0
        end
      end,
    },
    {
      "i64",
      BuiltinFunction.new 1 do |args|
        val = args[0]
        case val.type
        when ValueType::I32
          I64Value.new val.get_i32.to_i64
        when ValueType::I64
          I64Value.new val.get_i64.to_i64
        when ValueType::F32
          I64Value.new val.get_f32.to_i64
        when ValueType::F64
          I64Value.new val.get_f64.to_i64
        when ValueType::String
          I64Value.new val.get_string.to_i64
        else
          I64Value.new 0
        end
      end,
    },
    {
      "f32",
      BuiltinFunction.new 1 do |args|
        val = args[0]
        case val.type
        when ValueType::I32
          F32Value.new val.get_i32.to_f32
        when ValueType::I64
          F32Value.new val.get_i64.to_f32
        when ValueType::F32
          F32Value.new val.get_f32.to_f32
        when ValueType::F64
          F32Value.new val.get_f64.to_f32
        when ValueType::String
          F32Value.new val.get_string.to_f32
        else
          I32Value.new 0
        end
      end,
    },
    {
      "f64",
      BuiltinFunction.new 1 do |args|
        val = args[0]
        case val.type
        when ValueType::I32
          F64Value.new val.get_i32.to_f64
        when ValueType::I64
          F64Value.new val.get_i64.to_f64
        when ValueType::F32
          F64Value.new val.get_f32.to_f64
        when ValueType::F64
          F64Value.new val.get_f64.to_f64
        when ValueType::String
          F64Value.new val.get_string.to_f64
        else
          F64Value.new 0
        end
      end,
    },
    {
      "sin",
      BuiltinFunction.new 1 do |args|
        val = args[0]
        case val.type
        when ValueType::F32
          F32Value.new Math.sin val.get_f32
        when ValueType::F64
          F64Value.new Math.sin val.get_f64
        else
          NullValue.new
        end
      end,
    },
    {
      "cos",
      BuiltinFunction.new 1 do |args|
        val = args[0]
        case val.type
        when ValueType::F32
          F32Value.new Math.cos val.get_f32
        when ValueType::F64
          F64Value.new Math.cos val.get_f64
        else
          NullValue.new
        end
      end,
    },
    {
      "sqrt",
      BuiltinFunction.new 1 do |args|
        val = args[0]
        case val.type
        when ValueType::F32
          F32Value.new Math.sqrt val.get_f32
        when ValueType::F64
          F64Value.new Math.sqrt val.get_f64
        else
          NullValue.new
        end
      end,
    },
  ]

  initial_vars.each do |name_var|
    ctx.create_var(name_var[0], name_var[1])
  end

  ctx
end

case ARGV.size
when 0
  ctx = initial_context
  loop do
    input = gets
    if input == ".quit" || input.is_a?(Nil)
      break
    end
    program = Parser.new(Lexer.new(input).scan_tokens).parse_program
    program.each do |statement|
      statement.exec(ctx)
    end
  end
when 1
  ctx = initial_context
  input = File.read(ARGV[0])
  program = Parser.new(Lexer.new(input).scan_tokens).parse_program
  program.each do |statement|
    statement.exec(ctx)
  end
else
  puts "Error: Too many arguents"
  puts "  Use: pwo++ - to run interactive repl"
  puts "  Use: pwo++ <file.pwo> - to run file.pwo"
end
