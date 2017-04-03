class ConjunctionPremise < Law
  @available = true
  @abbrev = "ConPre"
  def apply state, wff
    return conjunction_premise state, wff
  end

  def self.applies? wff, premise
    return false unless premise
    return true if not wff.is_a? AtomicSentence and wff.connective.is_a? And
    return false
  end

  def conjunction_premise state, wff
    state.add_premise wff.element1
    state.add_premise wff.element2
    state.delete_premise wff
    return state
  end
  def to_s
    return "(∧, ⊧)"
  end
  def to_latex
    return "(\\wedge, \\models)"
  end
end
