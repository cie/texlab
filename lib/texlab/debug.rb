
# debug
def debug *args
  args.each {|a| STDERR.puts a.inspect}
  return *args
end

