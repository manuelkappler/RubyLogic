class RightHandDistributivity < Equivalence
  attr_reader :wff

  def initialize wff
    @original_wff = wff
    @wff = wff
    @handedness = "RH"
    self.apply
  end

  def apply
    # (q y r) x p = (q x p) y (q x r)
    major_connective = @wff.connective
    minor_connective = @wff.element1.connective
    p = @wff.element2
    q = @wff.element1.element1
    r = @wff.element1.element2
    @wff = CompositeSentence.new(minor_connective, CompositeSentence.new(major_connective, p, q), CompositeSentence.new(major_connective, p, r))
    @version = major_connective
  end

  def to_latex
    return "#{@original_wff.to_latex} \\equiv #{@wff.to_latex}"
  end

  def to_s
    return "#{@version.to_s}-Distr. (#{@handedness})"
  end
end

def righthanddistributivity? wff
  return false if wff.is_a? AtomicSentence
  # (q y r) x p = (q x p) y (q x r)
  return false if wff.element1.is_a? AtomicSentence
  # Main connective must be AND or OR
  return false unless wff.connective.is_a? And or wff.connective.is_a? Or
  main_connective = wff.connective
  minor_connective = (main_connective.is_a? And) ? Or : And
  return false unless wff.element1.connective.is_a? minor_connective
  return true
end
