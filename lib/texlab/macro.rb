# macros

$_macros={}

# a macro is available in tex (\asdf) and in ruby (:asdf.to_latex or $asdf). It will go to math
# mode
def macro hash
  hash.each do |key, value|
    value = value.latex!.to_latex_math
    define_latex_macro key, value
    define_symbol_macro key, value
    define_global_macro key, value
  end
end

# a text macro is available in tex (\asdf) and in ruby (:asdf, $asdf). It will not be
# forced to math mode 
def text_macro hash
  hash.each do |key, value|
    value = "\\text{#{value}}".latex!
    define_latex_macro key, value
    define_symbol_macro key, value
    define_global_macro key, value
  end
end

def define_symbol_macro key, value
  $_macros[key] = value
end

def define_latex_macro key, value
  $_erbout << "\\def\\#{key}{#{value}}"
end

def define_global_macro key, value
  eval "$#{key} = '#{value.gsub("\\","\\\\").gsub("'", "\\'")}'"
end

class Symbol
  # symbol's to_latex is the macro with the same name
  def to_latex
    $_macros[self] or raise "Undefined macro: #{self}"
  end

  def + str
    "#{to_latex}#{str}".latex!.to_latex_math
  end

  def * unit
    "\\unit[\\text{#{to_latex}}]{#{unit}}".latex!.to_latex_math
  end
end




%w(
  alpha beta gamma delta epsilon zeta eta theta iota kappa lambda mu nu xi omicron pi rho sigma tau upsilon phi chi psi omega
).each do |a|
  [a, a.capitalize].each do |b|
    key = b.to_sym
    value = "\\#{b}".latex!.to_latex_math
    define_symbol_macro key, value
    define_global_macro key, value
  end
end

('a'..'z').each do |a|
  [a, a.capitalize].each do |b|
    key = b.to_sym
    value = "#{b}".latex!.to_latex_math
    define_symbol_macro key, value
    define_global_macro key, value
  end
end


# units
$_units = {}

def unit hash
  # allow array keys to be DRY
  hash.each do |ks,v|
    [*ks].each do |k|
      $_units[k] = v
    end
  end
end

class Symbol
  def with_unit
    raise "No unit defined for #{self}" unless $_units.key? self
    if $_units[self]
      self * "(#{$_units[self]})"
    else
      to_latex
    end
  end
end


