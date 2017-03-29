class SubstituteEquivalents < Law
  @available = true
  @abbrev = "SubEq"

  def self.applies? wff, premise
    possible_equivs = find_equivalences wff
    return possible_equivs if possible_equivs.length > 0
    return false
  end

  def apply state, wff, idx 
    possible_subs = find_equivalences(wff)
    @equiv = possible_subs[idx].new wff
    return (substitute_equivalents state, wff, @equiv)
  end


  def substitute_equivalents state, wff, equiv
    if state.premises.any?{|x| x.is_equal? wff}
      # puts "Trying to replace premise"
      state.add_premise equiv.wff
      state.delete_premise wff
    else
      # puts "Trying to replace conclusion"
      state.add_conclusion equiv.wff
      state.delete_conclusion wff
    end
    puts state
    return state
  end


  def to_s
    return "Subst. Equiv."
  end

  def to_latex
    return @equiv.to_latex
  end
end

def find_equivalences wff
  all_equivalences = ObjectSpace.each_object(Class).select{|cl| cl < Equivalence}
  all_equivalences = all_equivalences.select{|x| send (x.to_s.downcase + "?").to_sym, wff}
  return all_equivalences
end