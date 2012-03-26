# This is the boot file to be loaded before parsing a .texlab file
#
$: << (ENV["TEXLAB"] + "/lib")
require "easystats"
require "plusminus"
require "to_latex"
require "gnuplot"
require "open3"

# tweak Hash
class Hash
  # Object-like behavior
  def method_missing name, *args
    name_string = name.to_s
    case name_string[-1]
    when "="
      self[name_string[0..-2].to_sym] = args[0]
    when "!"
      self[name_string[0..-2].to_sym] = {}
    when "?"
      !! self[name_string[0..-2]]
    else
      self[name]
    end
  end
end

module Enumerable
  # map-hash
  def mash
    res = {}
    each do |*x|
      k,v = yield(*x)
      res[k] = v
    end
    res
  end
end

class Hash
  def mash! &block
    replace mash(&block)
  end
end


# Average method for array with uncertainty calculation
class Array
  def average
    m = mean
    m.pm(Math.sqrt(m.delta**2 + (standard_deviation*3)**2))
  end
end


# latex generation helper
require "texlab/texlabfile"

$_latexfile = TexlabFile.new $_erbout

def documentHeader *args
  $_latexfile.documentHeader *args
end

def env *args
  $_latexfile.env(*args){yield}
end

def documentFooter
  puts "\\end{document}\n"
end


# table generation
#

def table title, settings={}
  @_table = {}
  yield
  entries = @_table
  $_latexfile.table(entries, title, settings)
end

def column title
  @_table_columns << (@_table_columns.last[title] || {})

  result = yield
  subcolumns = @_table_columns.pop

  unless subcolumns.empty?
    result = subcolumns
  end

  @_table_columns.last[title] = result
end

def row title
  @_table_columns = [@_table[title] || {}]
  yield
  @_table[title] = @_table_columns.first
end




def puts string
  $_erbout << string.latex! << "\n"
end



# plotting
#

require "gnuplot"

# override to have "w+" mode
def Gnuplot.open( persist=true )
  cmd = Gnuplot.gnuplot( persist ) or raise 'gnuplot not found'
  IO::popen( cmd, "w+") { |io| yield io }
end 

def plot title, opts={}
  placement = opts.delete(:placement) || "htbp"
  width   = opts.delete(:width) || "17cm"
  height = opts.delete(:height) || "10cm"
  cmd    = opts.delete(:cmd) || "plot"

  env :figure, "[#{placement}]" do
    env :center do
      @_datasets = []
      yield
      @_datasets

      Gnuplot.open do |gp|
        gp <<<<-GP
          set terminal latex size #{width}, #{height}
        GP

        Gnuplot::Plot.new(gp, cmd) do |plot|
          opts.each do |key, value|
            case value
            when true
              plot.send key
            else
              plot.send key, value
            end
          end

          @_datasets.each do |ds|
            plot.data << ds
          end
        end
        gp.close_write
        puts gp.readlines.join("\n")
      end
    end
    puts "\\caption{#{title}}"
  end
end

def splot title, opts={}, &block
  opts.cmd = "splot"
  plot title, opts, &block
end

def dataset *args
  if args.last.is_a? Hash
    opts = args.pop
  else 
    opts = {}
  end

  case args.first
  when String
    # simple function
    ds = Gnuplot::DataSet.new args.shift
  when nil
    # data
    @_datastrings = []
    yield

    c = @_datastrings.first.count
    data = (0...c).map do |i|
      @_datastrings.map{|t|t[i]}
    end

    ds = Gnuplot::DataSet.new data
  else
    raise ArgumentError, "Unnecessary parameters: #{args}"
  end
  
  # check args
  raise ArgumentError, "Unnecessary parameters: #{args}" unless args.empty?

  # tweak args (syntax candy)
  if opts.key? :title and not opts[:title]
    opts.delete(:title)
    opts[:notitle] = true
  end

  # send options
  opts.each do |key, value|
    case value
    when true
      ds.send key
    else
      ds.send :"#{key}=", value
    end
  end

  @_datasets << ds

end

def datastring arg
  @_datastrings << arg
end


# fitting
def fit expr, opts={}
  raise "via: is a necessary parameter" if not opts[:via]
  via = opts[:via]
  vars = via.split(",")

  using = opts[:using]

  @_datasets = []

  dataset do 
    yield
  end

  ds = @_datasets.first

  cmd = Gnuplot.gnuplot(true) or raise "gnuplot not found"
  errlines = []
  result = {}

  Open3.popen3(cmd) do |gp, out, err, external|
    vars.each do |var|
      gp << "#{var} = #{rand}\n"
    end
    gp <<<<-GP
      fit #{expr} '-' #{"using " + using if using} via #{via}
    GP
    gp << ds.to_gplot
    gp.close
    
    errlines = err.readlines
    errlines.each do |l|
      if l =~ /\A([a-zA-Z_][a-zA-Z0-9_]*)\s*=\s*([0-9eE.+-]+)\s*\+\/-\s*([0-9eE.+-]+)/
        result[$1.to_sym] = $2.to_f.pm($3.to_f)
      end
    end
  end

  vars.map do |v|
    result[v.to_sym] or raise "could not fit:\n" + errlines.join("\n")
  end
end


# macros

$_macros={}

# a macro is available in tex (\asdf) and in ruby (:asdf). It will go to math
# mode
def macro hash
  hash.each do |key, value|
    $_macros[key] = "\\ensuremath{#{value}}"
    puts "\\newcommand{\\#{key}}{\\ensuremath{#{value}}}"
  end
end

# a text macro is available in tex (\asdf) and in ruby (:asdf). It will not be
# forced to math mode 
def text_macro hash
  hash.each do |key, value|
    $_macros[key] = value
    puts "\\newcommand{\\#{key}}{#{value}}"
  end
end

class Symbol
  # symbol's to_latex is the macro with the same name
  def to_latex
    $_macros[self] or raise "Undefined macro: #{self}"
  end

  def + str
    "\\ensuremath{#{to_latex}#{str}}".latex!
  end
end


# debug
def debug *args
  args.each {|a| STDERR.puts a.inspect}
  return *args
end

# include Math
include Math