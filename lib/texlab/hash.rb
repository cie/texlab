
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

  def slice *args
    args.mash{|k| self[k]} 
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

