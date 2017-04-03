class Commutativity < Equivalence
  attr_reader :wff

  def initialize wff
    @original_wff = wff
    @wff = wff
    @connective = wff.connective
    self.apply
  end

  def apply
    @wff = CompositeSentence.new(@connective, @wff.element2, @wff.element1)
  end

  def to_s
    return "#{@connective.to_s}-Comm."
  end

  def to_latex
    return "#{@original_wff.to_latex} \\equiv #{@wff.to_latex}"
  end
end

def commutativity? wff
  return false if wff.is_a? AtomicSentence
  return true if wff.connective.is_a? And or wff.connective.is_a? Or
  return false
end
