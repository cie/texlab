# tikz
def tikz *libs
  $_erbout << "\\usepackage{tikz}\n"
  $_erbout << "\\usetikzlibrary{#{libs.join(",")}}\n" if libs.any?
end

