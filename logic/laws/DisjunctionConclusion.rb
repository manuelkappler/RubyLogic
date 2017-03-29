class DisjunctionConclusion < Law

  @available = true
  @abbrev = "OrCon"

  def apply state, wff
    raise LogicError unless state.disjunction_conclusion?
    return disjunction_conclusion state, wff
  end

  def self.applies? wff, premise
    return false if premise
    return true if not wff.is_a? AtomicSentence and wff.connective.is_a? Or
    return false
  end

  def disjunction_conclusion state, wff

    new_wff = CompositeSentence.new(wff.element1, Not.new)
    state.add_premise new_wff
    state.add_conclusion wff.element2
    state.delete_conclusion wff
    return state
  end
  def to_s
    return "(⊧, ∨)"
  end

  def to_latex
    return "(\\models, \\vee)"
  end

end
