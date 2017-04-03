class DisjunctionPremise < BranchingLaw
  @available = true
  @abbrev = "OrPre"

  def apply imp1, imp2, wff
    return disjunction_premise imp1, imp2, wff
  end

  def self.applies? wff, premise
    return false unless premise
    return true if not wff.is_a? AtomicSentence and wff.connective.is_a? Or
    return false
  end

  def disjunction_premise imp1, imp2, wff
    imp1.add_premise wff.element1
    imp1.delete_premise wff
    imp2.add_premise wff.element2
    imp2.delete_premise wff
    return [imp1, imp2]
  end

  def to_s
    return "(∨, ⊧)"
  end

  def to_latex
    return "(\\vee, \\models)"
  end
end
