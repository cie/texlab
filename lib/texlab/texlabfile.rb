# encoding: ASCII-8bit
require "latex"

class TexlabFile < LatexFile
  # create new instance.
  # @param _erbout the string or file to write to
  def initialize _erbout
    # we don't call super

    @_erbout = _erbout

    # replay actions in super

    @extras = {
      :documentclass => :article,
      :fontsize => "12pt"
    }

    #use defaults for unused entries:
    @indent = 0 # indent lines in blocks

    @usePackages = {
      :inputenc=>:latin1,
      :graphics=>:final,
      :graphicx=>:pdftex,
      :color=>:dvips,
      :amsfonts=>true,
      :subfigure=>true,
      :lscape=>true,
      :hyperref=>true,
      :amsmath=>true,
      :units=>true,
      :float=>true,
      :xcolor=>"table",
      :rmpage=>[:wider,:taller]
      #:subfig=>["lofdepth", "lotdepth"]
    }
      
    @default_table_align = 'c'

    @lastWasPrint = false
  end

  def puts string
    lines = string.split("\n")
    for line in lines
      @indent -= 2 if line[0,5]=='\\end{' && @indent >= 2
      if @lastWasPrint
        @_erbout << line.latex! << "\n"
        @lastWasPrint = false
      else
        @_erbout << (" " * @indent).latex! << line.latex! << "\n"
      end
      @indent += 2 if line[0,7]=='\\begin{'
    end
  end

  def print string
    @lastWasPrint = true
    @indent -= 2 if string[/\\end/]
    @indent += 2 if string[/\\begin/]
    @_erbout << string.latex! << "\n"
  end

  def prettyPrintCell x
    x.to_latex
  end

  def documentHeader extras={}
    @extras.merge! extras
    @usePackages.merge! extras[:usePackages] || {}
      
    dcsettings = [@extras[:fontsize]]
    dcsettings << "twocolumn" if @extras[:twocolumn]

    puts "\\documentclass[#{dcsettings.join(",")}]{#{@extras[:documentclass]}}"

    @usePackages.each do |package, settings|
      case settings
      when true then puts "\\usepackage{#{package}}"
      when Array  then puts "\\usepackage[#{settings.join(",")}]{#{package}}"
      else puts "\\usepackage[#{settings}]{#{package}}"
      end
    end
    #puts "\\addtolength{\\oddsidemargin}{-3.5cm}"
    #puts "\\addtolength{\\textwidth}{7cm}"
    #puts "\\addtolength{\\topmargin}{-3cm}"
    #puts "\\addtolength{\\textheight}{5cm}"
    puts "\\newcommand{\\hide}[1]{}"

    puts "\\special{landscape}" if @extras[:landscape]

    #puts "\\begin{document}"
    puts "\\DeclareGraphicsExtensions{.jpg,.pdf,.mps,.png}"
  end
  

  def env(name, *args)
    # overridden for compatibility with new Array#to_s
    puts "\\begin{#{name}}#{args.join("")}"
    yield if block_given?
    puts "\\end{#{name}}"
  end

  def table entries, caption, args={}

    # override defaults
    args = {
      :sort=> proc{0},
      :header_hlines=>true,
      :placement => (args[:label] ? 'htbp' : 'H'),
      :empty => "---"
    }.merge(args)


    args[:rowTitle] = args[:rowTitle].to_latex if args[:rowTitle]

    entries = convertKeysToLatex(entries)

    super(entries, caption, args)
  end

  def plain_table entries, caption, opts={}
    # capture output of table()
    temp_erbout = @_erbout; @_erbout = ""
    table(entries, caption, opts)
    src = @_erbout; @_erbout = temp_erbout

    src.sub!(/\A.*?\\begin{center}(.*)\\end{center}.*\z/m, '\1') or raise "internal error"
    src.sub!(/\\caption{#{caption}}/, "") or raise "internal error"

  end

  def tables data, caption, opts={}
    placement        = opts.delete(:placement) || "htbp"
    tableLandscape   = opts.delete(:landscape)
    tableFontSize    = opts.delete(:fontSize)  || @defaultTableFontSize
    tableLabel       = opts.delete(:label)     || ""
    tableCaption     = caption

    puts "\\begin{landscape}" if tableLandscape
    puts "\n\\begin{table}[#{placement}]\n\\begin{center}"
    puts "\\#{tableFontSize}" if tableFontSize
    
    puts data.map { |args|
      entries, caption, opts = *args
      "\\subtable[#{caption}]{#{plain_table(*args)}}"
    }.join("\\qquad")

    puts "\\caption{#{tableCaption}}\n" if tableCaption
    puts "\\label{tab:#{tableLabel}}" if tableLabel
    puts "\\end{center}\n\\end{table}\n"
    puts "\\end{landscape}" if @tableLandscape
  end

  private

  def convertKeysToLatex value
    case value
    when Hash
      value.mash{|k,v| [k.to_latex, convertKeysToLatex(v)] }
    else
      value
    end
  end

end
