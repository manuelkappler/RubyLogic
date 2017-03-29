class BiconditionalConclusion < BranchingLaw
  @available = true
  @abbrev = "IffConc"
  def apply imp1, imp2, wff
    return biconditional_conclusion imp1, imp2, wff
  end

  def self.applies? wff, premise
    return false if premise
    return true if not wff.is_a? AtomicSentence and wff.connective.is_a? Iff
    return false
  end

  def biconditional_conclusion imp1, imp2, wff
    imp1.add_premise wff.element1
    imp1.add_conclusion wff.element2
    imp1.delete_conclusion wff
    imp2.add_premise wff.element2
    imp2.add_conclusion wff.element1
    imp2.delete_conclusion wff
    return [imp1, imp2]
  end

  def to_s
    return "Biconditional Conclusion"
  end
  def to_latex
    return "(\\models, \\leftrightarrow)"
  end
end
