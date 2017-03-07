require_relative 'Equivalences'

class Law
  class << self; attr_reader :available, :abbrev end
end

class BranchingLaw < Law
end

class Given < Law
  @available = false

  def apply state
    return state
  end
  def to_s
    return "Given"
  end
end


class ConditionalConclusion < Law
  @available = true
  @abbrev = "IfCon"

  def apply state
    raise LogicError unless state.conditional_conclusion?
    return conditional_conclusion state
  end

  def conditional_conclusion state
    conclusion_conditionals = state.conclusion.select{|x| not x.is_a? Variable and x.connective.is_a? If}
    cond = resolve_ambiguities conclusion_conditionals, self.to_s
    state.add_premise cond.atom1
    state.add_conclusion cond.atom2
    state.delete_conclusion cond
    return state
  end

  def to_s
    return "Cond. Concl."
  end
end

class SubstituteEquivalents < Law
  @available = true
  @abbrev = "SubEq"

  def apply state
    possible_equivalences = {}
    state.premises.each{|x| possible_equivalences.merge! find_all_equivalences x}
    state.conclusion.each{|x| possible_equivalences.merge! find_all_equivalences x}
    possible_equivalences.reject!{|key, value| value.empty?}
    possible_equivalences.each{|k, v| puts "For subcomponent #{k.to_s}:"; v.each{|sub| puts "\t#{sub.to_s} => #{(sub.new k).wff.to_s}"}}
    chosen_wff = resolve_ambiguities possible_equivalences.keys.reject{|x| possible_equivalences[x].empty?}, "one of the above mentioned substitutions"
    chosen_sub = resolve_ambiguities possible_equivalences[chosen_wff], "the substitution to be applied"
    return substitute_equivalents state, chosen_wff, (chosen_sub.new chosen_wff).wff
  end

  def has_wff? element, wff
    if element.is_equal? wff
      return true
    else
      if element.is_a? Variable
        return false
      elsif element.is_unary? 
        return has_wff? element.atom1, wff 
      else
        return (has_wff? element.atom1, wff or has_wff? element.atom2, wff)
      end
    end
    return false
  end

  def replace_wff element, sub1, sub2
    if element.is_equal? sub1
      return sub2
    else
      if element.is_unary?
        return WFF.new((replace_wff element.atom1, sub1, sub2), element.connective)
      else
        if has_wff? element.atom1, sub1
          return WFF.new((replace_wff(element.atom1, sub1, sub2)), element.connective, element.atom2)
        else
          return WFF.new(element.atom1, element.connective, (replace_wff element.atom2, sub1, sub2))
        end
      end
    end
  end

  def substitute_equivalents state, sub1, sub2
    state.premises.select{|x| has_wff? x, sub1}.each do |equiv|
      state.add_premise replace_wff equiv, sub1, sub2
      state.delete_premise equiv
    end
    state.conclusion.select{|x| has_wff? x, sub1}.each do |equiv|
      state.add_conclusion replace_wff equiv, sub1, sub2
      state.delete_conclusion equiv
    end
    return state
  end

  def to_s
    return "Subst. Equiv."
  end
end

class Disjoining < Law

  @available = true
  @abbrev = "DJ"

  def apply state
    raise LogicError unless state.disjoining?
    return disjoin state
  end
  def disjoin state
    premise_conditionals = state.premises.select{|x| not x.is_a? Variable and x.connective.is_a? If and state.premises.any?{|y| y.is_equal? x.atom1}}
    cond = resolve_ambiguities premise_conditionals, self.to_s
    state.add_premise cond.atom1
    state.add_premise cond.atom2
    state.delete_premise cond
    return state
  end
  def to_s
    return "Disj."
  end
end

class ConjunctionPremise < Law
  @available = true
  @abbrev = "ConPre"
  def apply state
    raise LogicError unless state.conjunction_premise?
    return conjunction_premise state
  end

  def conjunction_premise state
    premise_conjunctions = state.premises.select{|x| not x.is_a? Variable and x.connective.is_a? And}
    conjunction = resolve_ambiguities premise_conjunctions, self.to_s
    state.add_premise conjunction.atom1
    state.add_premise conjunction.atom2
    state.delete_premise conjunction
    return state
  end
  def to_s
    return "(∧, ⊧)"
  end
end

class ReverseConjunctionPremise < Law
  @available = true
  @abbrev = "RConPre"

  def apply state
    raise LogicError unless state.reverse_conjunction_premise?
    return reverse_conjunction_premise state
  end

  def reverse_conjunction_premise state
    premises = state.premises
    if premises.length > 2
      conjunct1 = resolve_ambiguities premises, "Premises to Conjunction"
    else
      conjunct1 = premises[0]
      conjunct2 = premises[1]
    end
    remaining_premises = premises.reject{|x| x.is_equal? conjunct1}
    if remaining_premises.length > 1
      conjunct2 = resolve_ambiguities remaining_premises, "Premises to Conjuction"
    else
      conjunct2 = remaining_premises[0]
    end
    state.add_premise WFF.new(conjunct1, And.new, conjunct2)
    state.delete_premise conjunct1
    state.delete_premise conjunct2
    return state
  end
  def to_s
    return "(∧, ⊧)"
  end
end

class ConjunctionConclusion < BranchingLaw
  @available = true
  @abbrev = "AndCon"
  def apply imp1, imp2
    raise LogicError unless imp1.conjunction_conclusion?
    return conjunction_conclusion imp1, imp2
  end

  def conjunction_conclusion imp1, imp2
    conclusion_conjunctions = imp1.conclusion.select{|x| not x.is_a? Variable and x.connective.is_a? And}
    conjunction = resolve_ambiguities conclusion_conjunctions, self.to_s
    imp1.add_conclusion conjunction.atom1
    imp1.delete_conclusion conjunction
    imp2.add_conclusion conjunction.atom2
    imp2.delete_conclusion conjunction 
    return [imp1, imp2]
  end

  def to_s
    return "(⊧, ∧)"
  end
end

class DisjunctionPremise < BranchingLaw
  @available = true
  @abbrev = "OrPre"

  def apply imp1, imp2
    raise LogicError unless imp1.disjunction_premise?
    return disjunction_premise imp1, imp2
  end

  def disjunction_premise imp1, imp2
    premise_disjunctions = imp1.premises.select{|x| not x.is_a? Variable and x.connective.is_a? Or}
    disjunction = resolve_ambiguities premise_disjunctions, self.to_s
    imp1.add_premise disjunction.atom1
    imp1.delete_premise disjunction
    imp2.add_premise disjunction.atom2
    imp2.delete_premise disjunction
    return [imp1, imp2]
  end

  def to_s
    return "(∨, ⊧)"
  end
end

class DisjunctionConclusion < Law
  @available = true
  @abbrev = "OrCon"
  def apply state
    raise LogicError unless state.disjunction_conclusion?
    return disjunction_conclusion state
  end

  def disjunction_conclusion state

    conc_disjs = state.conclusion.select{|x| not x.is_a? Variable and x.connective.is_a? Or}
    disj = resolve_ambiguities conc_disjs, self.to_s
    new_wff = WFF.new(disj.atom1, Not.new)
    state.add_premise new_wff
    state.add_conclusion disj.atom2
    state.delete_conclusion disj
    return state
  end
  def to_s
    return "(⊧, ∨)"
  end

end

def is_affirmative? string
  return true if ["yes", "y", "yep"].include? string.downcase
  return false
end

def resolve_ambiguities list_of_formulae, law_string
    if list_of_formulae.length > 1
      puts ("Choose element to apply #{law_string} to:\n#{list_of_formulae.map.with_index{|x, i| i.to_s + ': ' + x.to_s}.join("\n")}").cyan
      selected = list_of_formulae[gets.chomp.to_i]
    else
      selected = list_of_formulae[0]
    end
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
