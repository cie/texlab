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


