class BiconditionalPremise < BranchingLaw
  @available = true
  @abbrev = "IffPre"

  def apply imp1, imp2, wff
    return biconditional_premise imp1, imp2, wff
  end

  def self.applies? wff, premise
    return false unless premise
    return true if not wff.is_a? AtomicSentence and wff.connective.is_a? Iff
    return false
  end

  def biconditional_premise imp1, imp2, wff
    imp1.add_premise wff.element1
    imp1.add_premise wff.element2
    imp1.delete_premise wff
    neg = Not.new
    imp2.add_premise CompositeSentence.new(neg, wff.element1)
    imp2.add_premise CompositeSentence.new(neg, wff.element2)
    imp2.delete_premise wff
    return [imp1, imp2]
  end

  def to_s
    return "Biconditional Premise"
  end
  def to_latex
    return "(\\leftrightarrow, \\models)"
  end

end
