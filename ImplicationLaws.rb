class Law
end

class BranchingLaw < Law
end

class Given < Law
  def apply state
    return state
  end
  def to_s
    return "Given"
  end
end


class ConditionalConclusion < Law

  def apply state
    raise LogicError unless state.conditional_conclusion?
    return conditional_conclusion state
  end

  def conditional_conclusion state
    state.conclusion.select{|x| not x.is_a? Variable and x.connective.is_a? If}.each do |cond|
      puts "Pushing antecedent to premises: #{cond.atom1}?"
      next unless is_affirmative? gets.chomp
      state.add_premise cond.atom1
      state.add_conclusion cond.atom2
      state.delete_conclusion cond
    end
    return state
  end

  def to_s
    return "Cond. Concl."
  end
end

class SubstituteEquivalents < Law
  def apply state
    puts "Enter the expression you want to substitute".cyan
    vars = state.get_vars
    vars, sub1 = parse_string(gets.strip, vars)
    puts "Enter the expression you want to substitute it with".cyan
    vars, sub2 = parse_string(gets.strip, vars)
    return substitute_equivalents state, sub1, sub2
  end

  def substitute_equivalents state, sub1, sub2
    if (not state.get_conclusion.any?{|x| x.is_equal? sub1} and not state.get_premises.any?{|x| x.is_equal? sub1})
      raise LogicError
    else
      state.premises.select{|x| x.is_equal? sub1}.each do |equiv|
        state.add_premise sub2
        state.delete_premise sub1
      end
      state.conclusion.select{|x| x.is_equal? sub1}.each do |equiv|
        state.add_conclusion sub2
        state.delete_conclusion sub1
      end
    end
    return state
  end

  def to_s
    return "Subst. Equiv."
  end
end

class Disjoining < Law
  def apply state
    raise LogicError unless state.disjoining?
    return disjoin state
  end
  def disjoin state
    state.premises.select{|x| not x.is_a? Variable and x.connective.is_a? If}.each do |cond|
      puts "Disjoin conditional #{cond.to_s}?"
      next unless is_affirmative? gets.chomp
      state.add_premise cond.atom1
      state.add_premise cond.atom2
      state.delete_premise cond
    end
    return state
  end
  def to_s
    return "Disj."
  end
end

class ConjunctionPremise < Law
  def apply state
    raise LogicError unless state.conjunction_premise?
    return conjunction_premise state
  end
  def conjunction_premise state
    state.premises.select{|x| not x.is_a? Variable and x.connective.is_a? And}.each do |conj|
      puts "Split #{conj} into #{conj.atom1} and #{conj.atom2}?"
      next unless is_affirmative? gets.chomp
      state.add_premise conj.atom1
      state.add_premise conj.atom2
      state.delete_premise conj
    end
    return state
  end
  def to_s
    return "∧ | ⊫"
  end
end

class ConjunctionConclusion < BranchingLaw
  def apply imp1, imp2
    raise LogicError unless imp1.conjunction_conclusion?
    return conjunction_conclusion imp1, imp2
  end

  def conjunction_conclusion imp1, imp2
    conclusion_conjunctions = imp1.conclusion.select{|x| not x.is_a? Variable and x.connective.is_a? Or}
    if conclusion_conjunctions.length > 1
      puts ("Enter number of conjunction to be split #{conclusion_conjunctions.map_with_index{|x, i| i.to_s + ': ' + x.to_s}}").cyan
      conjunction = conclusion_conjunctions[gets.chomp.to_i]
    end
    imp1.add_conclusion conjunction.atom1
    imp1.delete_conclusion conjunction
    imp2.add_conclusion conjunction.atom2
    imp2.delete_conclusion conjunction 
    return [imp1, imp2]
  end

  def to_s
    return "⊫ | ∧"
  end
end

class DisjunctionPremise < BranchingLaw
  def apply imp1, imp2
    raise LogicError unless imp1.disjunction_premise?
    return disjunction_premise imp1, imp2
  end

  def disjunction_premise imp1, imp2
    premise_disjunctions = imp1.premises.select{|x| not x.is_a? Variable and x.connective.is_a? Or}
    if premise_disjunctions.length > 1
      puts ("Enter number of disjunction to be split #{premise_disjunctions.map_with_index{|x, i| i.to_s + ': ' + x.to_s}}").cyan
      disjunction = premise_disjunctions[gets.chomp.to_i]
    else
      disjunction = premise_disjunctions[0]
    end
    imp1.add_premise disjunction.atom1
    imp1.delete_premise disjunction
    imp2.add_premise disjunction.atom2
    imp2.delete_premise disjunction
    return [imp1, imp2]
  end

  def to_s
    return "∨ | ⊫"
  end
end

class DisjunctionConclusion < Law
  def apply state
    raise LogicError unless state.disjunction_conclusion?
    return disjunction_conclusion state
  end

  def disjunction_conclusion state
    state.conclusion.select{|x| not x.is_a? Variable and x.connective.is_a? Or}.each do |disj|
      puts "Split #{disj} into #{disj.atom2} and move ¬#{disj.atom1} to premises?"
      next unless is_affirmative? gets.chomp
      new_wff = WFF.new(disj.atom1, Not.new)
      state.add_premise new_wff
      state.add_conclusion disj.atom2
      state.delete_conclusion disj
    end
    return state
  end
  def to_s
    return "⊫ | ∨"
  end

end

def is_affirmative? string
  return true if ["yes", "y", "yep"].include? string.downcase
  return false
end

=begin
    if ["monotonicity"].include? input.downcase
      puts "Enter the formula you would like to add to the premises".blue
      input = gets.strip
      vars, new_wff = parse_string(input, vars)
      step = Step.new @current_state, new_wff
      @steps << step
    else
      begin
        eval("implication.#{LAWS[input]}")
      rescue LogicError
        puts "You can't use #{input} here"
      end
=end

=begin

  def monotonicity! additional_wff
    add_premise additional_wff
  end

  def inconsistent_premises?
    #TODO Implement
  end

  def inconsistent_conclusion?
    #TODO Implement
  end


  
  def conjunction_conclusion?
    return true unless @conclusion.select{|x| not x.is_a? Variable and x.connective.is_a? And}.length == 0
    return false
  end


  def conjunction_conclusion!
    #TODO Implement
    # Note that this requires splitting the derivation into two parts, which can be tricky to implement (not sure yet how)
    # Similar problem applies to disjunction_premise
  end



=end
