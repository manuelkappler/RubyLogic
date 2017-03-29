class ConjunctionConclusion < BranchingLaw
  @available = true
  @abbrev = "AndCon"

  def apply imp1, imp2, wff
    raise LogicError unless imp1.conjunction_conclusion?
    return conjunction_conclusion imp1, imp2, wff
  end

  def self.applies? wff, premise
    return false if premise
    return true if not wff.is_a? AtomicSentence and wff.connective.is_a? And
    return false
  end

  def conjunction_conclusion imp1, imp2, wff
    imp1.add_conclusion wff.element1.
    imp1.delete_conclusion wff 
    imp2.add_conclusion wff.element2
    imp2.delete_conclusion wff
    return [imp1, imp2]
  end

  def to_s
    return "(⊧, ∧)"
  end
  def to_latex
    return "(\\models, \\wedge)"
  end
end
