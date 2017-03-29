class Connective
  include Comparable

  attr_reader(:precedence)

  def to_s
    return @symbol
  end

  def to_latex
    return @latex
  end

  def <=>(other_connective)
    raise ArgumentError unless other_connective.is_a? Connective
    if self.precedence < other_connective.precedence
      return 1
    elsif self.precedence > other_connective.precedence
      return -1
    else
      return 0
    end
  end
end
