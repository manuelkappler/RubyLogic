class LHEqualitySubstitution < Law
  @available = true
  @abbrev = "ESL 1->2"

  def self.to_latex
    return "ESL #{@wff.constants[0]} \\Rightarrow #{@wff.constants[1]}"
  end

  def apply state, wff
    @wff = wff
    return substitute_all state, wff
  end

  def self.applies? wff, premise=true
    return false unless wff.is_a? AtomicSentence
    return true if wff.predicate.class == Equality
    return false
  end

  def substitute_all state, wff
    from_term, to_term = [wff.constants[0], wff.constants[1]]
    state.premises.reject{|x| x.is_a? AtomicSentence and x.predicate.class == Equality}.each do |prem|
      state.add_premise substitute(prem, from_term, to_term)
      state.delete_premise prem
    end
    state.add_conclusion substitute(state.conclusion, from_term, to_term) unless state.conclusion.is_a? AtomicSentence and state.conclusion.predicate.class == Equality
    return state
  end

  def substitute wff, term_from, term_to
    if wff.is_a? AtomicSentence
      return AtomicSentence.new(wff.predicate, wff.constants.map{|x| x == term_from ? term_to : x})
    else
      if wff.connective.is_a? Not
        return CompositeSentence.new(Not.new, substitute(wff.element1, term_from, term_to))
      else
        return CompositeSentence.new(wff.connective, substitute(wff.element1, term_from, term_to), substitute(wff.element2, term_from, term_to))
      end
    end
  end
  def to_latex
    return "ESL #{@wff.constants[0]} \\Rightarrow #{@wff.constants[1]}"
  end

  def to_s
    return "ESL #{@wff.constants[0]} ⇒  #{@wff.constants[1]}"
  end


end

class RHEqualitySubstitution < Law
  @available = true
  @abbrev = "ESL 2->1"

  def self.to_latex
    return "ESL #{@wff.constants[1]} \\Rightarrow #{@wff.constants[0]}"
  end


  def apply state, wff
    @wff = wff
    return substitute_all state, wff
  end

  def self.applies? wff, premise=true
    return false unless wff.is_a? AtomicSentence
    return true if wff.predicate.class == Equality
    return false
  end

  def substitute_all state, wff
    from_term, to_term = [wff.constants[1], wff.constants[0]]
    state.premises.reject{|x| x.is_a? AtomicSentence and x.predicate.class == Equality}.each do |prem|
      state.add_premise substitute(prem, from_term, to_term)
      state.delete_premise prem
    end
    state.add_conclusion substitute(state.conclusion, from_term, to_term) unless state.conclusion.is_a? AtomicSentence and state.conclusion.predicate.class == Equality
    return state
  end

  def substitute wff, term_from, term_to
    if wff.is_a? AtomicSentence
      return AtomicSentence.new(wff.predicate, wff.constants.map{|x| x == term_from ? term_to : x})
    else
      if wff.connective.is_a? Not
        return CompositeSentence.new(Not.new, substitute(wff.element1, term_from, term_to))
      else
        return CompositeSentence.new(wff.connective, substitute(wff.element1, term_from, term_to), substitute(wff.element2, term_from, term_to))
      end
    end
  end

  def to_latex
    return "ESL #{@wff.constants[1]} \\Rightarrow #{@wff.constants[0]}"
  end

  def to_s
    return "ESL #{@wff.constants[1]} ⇒  #{@wff.constants[0]}"
  end


end
