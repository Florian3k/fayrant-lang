require "./parser/lexer.cr"
require "./parser/parser.cr"
require "./interpreter/context.cr"

include FayrantLang

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
  puts "  Use: fayrant - to run interactive repl"
  puts "  Use: fayrant <file.fy> - to run file.fy"
end
