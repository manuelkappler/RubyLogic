class ContradictoryConclusion < Law

  @available = true
  @abbrev = "CC"

  def self.applies? wff, premise
    premise ? (return false) : (return true)
  end

  def apply state, wff
    state.add_premise CompositeSentence.new(Not.new, wff)
    state.delete_conclusion wff
    state.add_conclusion Contradiction.new
    return state
  end

  def to_s
    return "CC"
  end

  def to_latex
    return "(\\models, \\bot)"
  end

end
