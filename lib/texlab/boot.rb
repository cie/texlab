# This is the boot file to be loaded before parsing a .texlab file
# encoding: ASCII-8bit
require "easystats"
require "plusminus"
require "to_latex"
require "gnuplot"
require "open3"

# tweak Array
class Array
  def extract_options!
    if last.is_a? Hash
      pop
    else
      {}
    end
  end
end

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

def puts string
  $_erbout << string.to_latex << "\n"
end

# table generation
#

def table title, settings={}
  @_table = {}
  yield
  entries = @_table

  unless @_tables
    $_latexfile.table(entries, title, settings)
  else
    @_tables << [entries, title, settings]
  end
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

def tables *args
  opts = args.extract_options!
  caption = args.shift

  @_tables = []
  yield

  $_latexfile.tables(@_tables, caption, opts)

  @_tables = nil
end


# Figure generation
#

def figure *args
  opts = args.extract_options!
  caption = args.shift
  format = opts[:width] ? "width=#{opts[:width]}" : opts[:format]
  label = opts[:label]
  filename = opts[:filename]
  if @_figures
    @_figures << Figure.new(format, filename, caption, label)
  else
    raise "not implemented"
  end
end

def figures *args
  opts = args.extract_options!
  placement = opts.delete(:placement) || "htbp"
  label = opts.delete(:label)
  newPageThreshold = opts.delete(:newPageThreshold) || 29
  caption = args.shift

  @_figures = []
  yield

  $_latexfile.figures(caption, @_figures, newPageThreshold, placement, label)

  @_figures = nil
end


# plotting
#

require "gnuplot"

# override to have "w+" mode
def Gnuplot.open( persist=true )
  cmd = Gnuplot.gnuplot( persist ) or raise 'gnuplot not found'
  IO::popen( cmd, "w+") { |io| yield io }
end 

def plot *args
  opts = args.extract_options!
  title = args[0]

  placement = opts.delete(:placement) || "htbp"
  width   = opts.delete(:width) || "17cm"
  height = opts.delete(:height) || "10cm"
  cmd    = opts.delete(:cmd) || "plot"

  env :figure, "[#{placement}]" do
    env :center do
      @_datasets = []
      yield
      @_datasets

      gnuplot = Gnuplot.gnuplot(true) or raise "gnuplot not found"
      Open3.popen3(gnuplot) do |gp, out, err, external|
        gp <<<<-GP
          set terminal latex size #{width}, #{height}
        GP

        Gnuplot::Plot.new(gp, cmd) do |plot|
          opts.each do |key, value|
            case value
            when true
              plot.send key
            else
              plot.send key, value.gsub(/([\\ ])/, "\\\\\\1")
            end
          end

          @_datasets.each do |ds|
            plot.data << ds
          end
        end
        gp.close
        $_erbout << out.readlines.join("\n")

        if not external.value.success?
          errlines = err.readlines
          raise "could not plot:\n" + errlines.join("\n")
        end
      end
    end
    $_erbout << "\\caption{#{title}}" if title
  end
end

def splot *args, &block
  opts = args.extract_options!
  opts.cmd = "splot"
  plot *args, opts, &block
end

def dataset *args
  opts = args.extract_options!

  data = args.shift
  data_is_expr = !!data
  if data
    # simple function
    ds = Gnuplot::DataSet.new data
  else
    # data
    @_datastrings = []
    yield

    c = @_datastrings.first.count
    data = (0...c).map do |i|
      @_datastrings.map{|t|t[i]}
    end

    ds = Gnuplot::DataSet.new data
  end
  
  # check args
  raise ArgumentError, "Unnecessary parameters: #{args}" unless args.empty?

  # tweak args (syntax candy)
  opts[:title] = nil unless data_is_expr or opts.has_key? :title
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

def data *args
  datastring args
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

  errlines = []
  result = {}

  gnuplot = Gnuplot.gnuplot(true) or raise "gnuplot not found"
  Open3.popen3(gnuplot) do |gp, out, err, external|
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

# a macro is available in tex (\asdf) and in ruby (:asdf.to_latex or $asdf). It will go to math
# mode
def macro hash
  text_macro hash.mash{|key, value| [key, value.latex!.to_latex_math] }
end

# a text macro is available in tex (\asdf) and in ruby (:asdf). It will not be
# forced to math mode 
def text_macro hash
  hash.each do |key, value|
    $_macros[key] = value
    eval "$#{key} = '#{value.gsub("\\","\\\\").gsub("'", "\\'")}'"
    $_erbout << "\\def\\#{key}{#{value}}"
  end
end

class Symbol
  # symbol's to_latex is the macro with the same name
  def to_latex
    $_macros[self] or raise "Undefined macro: #{self}"
  end

  def + str
    "#{to_latex}#{str}".latex!.to_latex_math
  end
end


# debug
def debug *args
  args.each {|a| STDERR.puts a.inspect}
  return *args
end

# include Math
include Math

# degree radian
def degrees x
  x * 180.0 / Math::PI
end

def radians x
  x / 180.0 * Math::PI
end
