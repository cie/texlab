require "easystats"

# Average method for array with uncertainty calculation
class Array
  def average
    m = mean
    m.pm(Math.sqrt(m.delta**2 + (standard_deviation*3)**2))
  end
end
