class ConditionalConclusion < Law
  @available = true
  @abbrev = "IfCon"

  def apply state, wff
    raise LogicError unless state.conditional_conclusion?
    return conditional_conclusion state, wff
  end

  def self.applies? wff, premise
    return false if premise
    return true if not wff.is_a? AtomicSentence and wff.connective.is_a? If
    return false
  end

  def conditional_conclusion state, wff
    state.add_premise wff.element1
    state.add_conclusion wff.element2
    state.delete_conclusion wff
    return state
  end

  def to_s
    return "Cond. Concl."
  end

  def to_latex
    return "(\\models, \\rightarrow)"
  end
end
