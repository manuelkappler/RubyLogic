class ConditionalPremise < BranchingLaw

  @available = true
  @abbrev = "IfPre"

  def self.applies? wff, premise
    return false unless premise
    return true if (not wff.is_a? AtomicSentence) and wff.connective.is_a? If
    return false
  end

  def apply imp1, imp2, wff
    return condprem imp1, imp2, wff
  end

  def condprem imp1, imp2, wff
    imp1.add_premise CompositeSentence.new(Not.new, wff.element1) 
    puts imp1
    imp1.delete_premise wff
    puts imp1
    imp2.add_premise wff.element2
    imp2.delete_premise wff
    return [imp1, imp2]
  end
  def to_s
    return "Cond. Premise"
  end
  def to_latex
    return "(\\rightarrow, \\models)"
  end
end
