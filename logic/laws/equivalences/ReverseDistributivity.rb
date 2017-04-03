class ReverseDistributivity < Equivalence
  attr_reader :wff

  def initialize wff
    raise LogicError unless reversedistributivity? wff
    @original_wff = wff
    @wff = wff
    self.apply
  end 

  def apply
    # (p ∧ q) ∨ r => (p ∨ q) ∧ (p ∨ r)
    major_connective = @wff.element1.connective
    minor_connective = @wff.connective
    if @wff.element1.element1.is_equal? @wff.element2.element1
      p = @wff.element1.element1
      q = @wff.element1.element2 
      r = @wff.element2.element2
    else
      p = @wff.element1.element2
      q = @wff.element1.element1
      r = @wff.element2.element1
    end
    @version = major_connective
    @wff = CompositeSentence.new(major_connective, p, CompositeSentence.new(minor_connective, q, r))
  end

  def to_s
    return "#{@version.to_s} - Distributivity"
  end

  def to_latex
    return "#{@original_wff.to_latex} \\equiv #{@wff.to_latex}"
  end
end

def reversedistributivity? wff
  return false if wff.is_a? AtomicSentence
  begin
    # Main connective must be AND or OR
    return false unless wff.connective.is_a? And or wff.connective.is_a? Or
    # Both atoms must be the opposite connective
    return false unless [wff.element1, wff.element2].all?{|x| not x.is_a? AtomicSentence and x.connective.is_a? ((wff.connective.is_a? And) ? Or : And)}
    # One atom.atom must be the same in each of the atoms 
    return false unless wff.element1.element1.is_equal? wff.element2.element1 or wff.element1.element2.is_equal? wff.element2.element2
    return true
  rescue Exception => e
    puts e.message
    return false
  end
end
