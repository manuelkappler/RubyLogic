class ContradictoryConclusion < Law

  @available = true
  @abbrev = "CC"

  def self.applies? wff, premise
    premise ? (return false) : (return true)
  end

  def apply state, wff
    if wff.is_a? CompositeSentence and wff.connective.is_a? Not
      state.add_premise wff.element1
    else
      state.add_premise CompositeSentence.new(Not.new, wff)
    end
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
