class DeMorgan < Equivalence

  attr_reader :wff

  def initialize wff
    @wff = wff
    @original_wff = wff
    @connective = wff.element1.connective
    self.apply
  end

  def apply
    puts "In apply demorgan, cur_wff = #{self.wff.to_s}"
    cur_wff = self.wff
    inside = cur_wff.element1
    neg = Not.new
    negated_el1 = (inside.element1.is_a? CompositeSentence and inside.element1.connective.is_a? Not) ?  inside.element1.element1 : CompositeSentence.new(neg, inside.element1)
    negated_el2 = (inside.element2.is_a? CompositeSentence and inside.element2.connective.is_a? Not) ?  inside.element2.element1 : CompositeSentence.new(neg, inside.element2)
    if @connective.is_a? And
      @wff = CompositeSentence.new(Or.new, negated_el1, negated_el2)
    elsif @connective.is_a? Or
      @wff = CompositeSentence.new(And.new, negated_el1, negated_el2)
    elsif @connective.is_a? If
      @wff = CompositeSentence.new(And.new, inside.element1, negated_el2)
    elsif @connective.is_a? Iff
      @wff = CompositeSentence.new(Or.new, CompositeSentence.new(neg, CompositeSentence.new(If.new, inside.element1, inside.element2)), CompositeSentence.new(neg, CompositeSentence.new(If.new, negated_el1, negated_el2)))
    end
  end

  def to_s
    return "Subst. Eq. ¬#{@connective.to_s}"
  end
  def to_latex
    return "Subst. Eq. \\neg #{@connective.to_latex}"
  end
end

def demorgan? wff
  begin
    return true if wff.connective.is_a? Not and (wff.element1.connective.is_a? And or wff.element1.connective.is_a? Or or wff.element1.connective.is_a? If or wff.element1.connective.is_a? Iff)
    return false
  rescue
    return false
  end
end
