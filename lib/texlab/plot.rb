# plotting
#

require "gnuplot"
require "open3"

# override to have "w+" mode
def Gnuplot.open( persist=true )
  cmd = Gnuplot.gnuplot( persist ) or raise 'gnuplot not found'
  IO::popen( cmd, "w+") { |io| yield io }
end 

def plot *args
  opts = args.extract_options!
  title = args[0]

  placement = opts.delete(:placement) || (opts[:label] ? "htbp" : "H")
  width   = opts.delete(:width) || "17cm"
  height = opts.delete(:height) || "10cm"
  cmd    = opts.delete(:cmd) || "plot"
  label = opts.delete(:label)
  debug = opts.delete(:debug)

  env :figure, "[#{placement}]" do
    env :center do
      @_datasets = []
      yield
      @_datasets

      gnuplot = Gnuplot.gnuplot(true) or raise "gnuplot not found"
      Open3.popen3(gnuplot) do |gp, out, err, external|
        gp = STDERR if debug
        gp <<<<-GP
          set terminal latex size #{width}, #{height}
        GP

        Gnuplot::Plot.new(gp, cmd) do |plot|
          opts.each do |key, value|
            case value
            when true
              plot.send key
            when false
              gp << "unset #{key}\n"
            else
              plot.send key, value.to_s.gsub(/([\\])/, "\\\\\\1")
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
    $_erbout << "\\label{#{label}}" if label
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
      @_datastrings.map do |t|
        case value = t[i]
        when String
          "\"#{value.to_s.gsub(/([\\"])/, "\\\\\\1")}\""
        else
          value.to_s
        end
      end
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


