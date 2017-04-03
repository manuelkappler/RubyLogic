class DoubleNegation < Equivalence
  attr_reader :wff

  def initialize wff
    @original_wff = wff
    @wff = wff
    self.apply
  end

  def apply
    @wff = @wff.element1.element1
  end

  def to_s
    return "DN"
  end

  def to_latex
    return "#{@original_wff.to_latex} \\equiv #{@wff.to_latex}"
  end
end

def doublenegation? wff
  begin
    return true if wff.is_a CompositecSentence and wff.element1.is_a? AtomicSentence and wff.connective.is_a? Not and wff.element1.connective.is_a? Not
  rescue
    return false
  end
  return false
end
