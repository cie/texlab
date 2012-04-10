# latex generation helper
require "plusminus"
require "to_latex"
require "nio/percent_fmt"

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


