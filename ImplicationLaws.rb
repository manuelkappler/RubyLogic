require_relative 'Equivalences'

class Law
  class << self; attr_reader :available, :abbrev end
end

class BranchingLaw < Law
end

class Given < Law
  @available = false

  def apply state, wff=nil
    return state
  end
  def to_s
    return "Given"
  end
  def to_latex
    return "(Given)"
  end
end


class ConditionalConclusion < Law
  @available = true
  @abbrev = "IfCon"

  def apply state, wff
    raise LogicError unless state.conditional_conclusion?
    return conditional_conclusion state, wff
  end

  def self.applies? wff, premise
    return false if premise
    return true if not wff.is_a? Variable and wff.connective.is_a? If
    return false
  end

  def conditional_conclusion state, wff
    state.add_premise wff.atom1
    state.add_conclusion wff.atom2
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

class ConditionalPremise < BranchingLaw

  @available = true
  @abbrev = "IfPre"

  def self.applies? wff, premise
    return false unless premise
    return true if not wff.is_a? Variable and wff.connective.is_a? If
    return false
  end

  def apply imp1, imp2, wff
    return condprem imp1, imp2, wff
  end

  def condprem imp1, imp2, wff
    imp1.add_premise WFF.new(wff.atom1, Not.new) 
    puts imp1
    imp1.delete_premise wff
    puts imp1
    imp2.add_premise wff.atom2
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

class ConjunctionPremise < Law
  @available = true
  @abbrev = "ConPre"
  def apply state, wff
    return conjunction_premise state, wff
  end

  def self.applies? wff, premise
    return false unless premise
    return true if not wff.is_a? Variable and wff.connective.is_a? And
    return false
  end

  def conjunction_premise state, wff
    state.add_premise wff.atom1
    state.add_premise wff.atom2
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

class ConjunctionConclusion < BranchingLaw
  @available = true
  @abbrev = "AndCon"

  def apply imp1, imp2, wff
    raise LogicError unless imp1.conjunction_conclusion?
    return conjunction_conclusion imp1, imp2, wff
  end

  def self.applies? wff, premise
    return false if premise
    return true if not wff.is_a? Variable and wff.connective.is_a? And
    return false
  end

  def conjunction_conclusion imp1, imp2, wff
    imp1.add_conclusion wff.atom1
    imp1.delete_conclusion wff 
    imp2.add_conclusion wff.atom2
    imp2.delete_conclusion wff
    return [imp1, imp2]
  end

  def to_s
    return "(⊧, ∧)"
  end
  def to_latex
    return "(\\models, \\wedge)"
  end
end

class DisjunctionPremise < BranchingLaw
  @available = true
  @abbrev = "OrPre"

  def apply imp1, imp2, wff
    raise LogicError unless imp1.disjunction_premise?
    return disjunction_premise imp1, imp2, wff
  end

  def self.applies? wff, premise
    return false unless premise
    return true if not wff.is_a? Variable and wff.connective.is_a? Or
    return false
  end

  def disjunction_premise imp1, imp2, wff
    imp1.add_premise wff.atom1
    imp1.delete_premise wff
    imp2.add_premise wff.atom2
    imp2.delete_premise wff
    return [imp1, imp2]
  end

  def to_s
    return "(∨, ⊧)"
  end

  def to_latex
    return "(\\vee, \\models)"
  end
end

class DisjunctionConclusion < Law

  @available = true
  @abbrev = "OrCon"

  def apply state, wff
    raise LogicError unless state.disjunction_conclusion?
    return disjunction_conclusion state, wff
  end

  def self.applies? wff, premise
    return false if premise
    return true if not wff.is_a? Variable and wff.connective.is_a? Or
    return false
  end

  def disjunction_conclusion state, wff

    new_wff = WFF.new(wff.atom1, Not.new)
    state.add_premise new_wff
    state.add_conclusion wff.atom2
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

class BiconditionalPremise < BranchingLaw
  @available = true
  @abbrev = "IffPre"

  def apply imp1, imp2, wff
    return biconditional_premise imp1, imp2, wff
  end

  def self.applies? wff, premise
    return false unless premise
    return true if not wff.is_unary? and wff.connective.is_a? Iff
    return false
  end

  def biconditional_premise imp1, imp2, wff
    imp1.add_premise wff.atom1
    imp1.add_premise wff.atom2
    imp1.delete_premise wff
    neg = Not.new
    imp2.add_premise WFF.new(wff.atom1, neg)
    imp2.add_premise WFF.new(wff.atom2, neg)
    imp2.delete_premise wff
    return [imp1, imp2]
  end

  def to_s
    return "Biconditional Premise"
  end
  def to_latex
    return "(\\leftrightarrow, \\models)"
  end

end

class BiconditionalConclusion < BranchingLaw
  @available = true
  @abbrev = "IffConc"
  def apply imp1, imp2, wff
    return biconditional_conclusion imp1, imp2, wff
  end

  def self.applies? wff, premise
    return false if premise
    return true if not wff.is_unary? and wff.connective.is_a? Iff
    return false
  end

  def biconditional_conclusion imp1, imp2, wff
    imp1.add_premise wff.atom1
    imp1.add_conclusion wff.atom2
    imp1.delete_conclusion wff
    imp2.add_premise wff.atom2
    imp2.add_conclusion wff.atom1
    imp2.delete_conclusion wff
    return [imp1, imp2]
  end

  def to_s
    return "Biconditional Conclusion"
  end
  def to_latex
    return "(\\models, \\leftrightarrow)"
  end
end

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
      puts "Trying to replace premise"
      state.add_premise equiv.wff
      state.delete_premise wff
    else
      puts "Trying to replace conclusion"
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

class ContradictioryConclusion < Law

  @available = true
  @abbrev = "CC"

  def self.applies? wff, premise
    premise ? (return false) : (return true)
  end

  def apply state, wff
    state.add_premise WFF.new(wff, Not.new)
    state.delete_conclusion wff
    state.add_conclusion Contradiction.new
    return state
  end

  def to_s
    return "Subst. Equiv."
  end

  def to_latex
    return "(\\models, \\bot)"
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
=begin
         def apply state
    possible_equivalences = {}
    state.premises.each{|x| possible_equivalences.merge! find_all_equivalences x}
    state.conclusion.each{|x| possible_equivalences.merge! find_all_equivalences x}
    possible_equivalences.reject!{|key, value| value.empty?}
    possible_equivalences.each{|k, v| puts "For subcomponent #{k.to_s}:"; v.each{|sub| puts "\t#{sub.to_s} => #{(sub.new k).wff.to_s}"}}
    chosen_wff = resolve_ambiguities possible_equivalences.keys.reject{|x| possible_equivalences[x].empty?}, "one of the above mentioned substitutions"
    chosen_sub = resolve_ambiguities possible_equivalences[chosen_wff], "the substitution to be apllied"
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
=end
