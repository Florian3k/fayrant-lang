case ARGV.size
when 0
  puts "Running REPL..."
when 1
  puts "Running interpreter on [#{ARGV[0]}]"
else
  puts "Error: Too many arguents"
  puts "  Use: fayrant - to run interactive repl"
  puts "  Use: fayrant <file.fy> - to run file.fy"
end
