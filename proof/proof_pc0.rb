# Load syntax and semantics
 
require_relative '../logic/syntax_pc0'
require_relative '../logic/semantics_pc0'

# Load helper functions: the ProofTree class which keeps track of the proof, and parse_string which turns strings into an Implication claim
require_relative 'lib/ProofTree'
require_relative 'lib/parse_string'

# Load the implication helper class
# TODO: Implication helper should be moved and made logic-specific

require_relative '../Implication'

# Load DeMorgan equivalences (no other equivalence laws needed or used)

require_relative "../logic/laws/equivalences/Equivalence"
require_relative "../logic/laws/equivalences/DeMorgan"

# Load all Implication Laws for pc0

require_relative "../logic/laws/Law"
require_relative "../logic/laws/BranchingLaw"
require_relative "../logic/laws/Given"
require_relative "../logic/laws/ConjunctionPremise"
require_relative "../logic/laws/ConjunctionConclusion"
require_relative "../logic/laws/DisjunctionPremise"
require_relative "../logic/laws/DisjunctionConclusion"
require_relative "../logic/laws/ConditionalPremise"
require_relative "../logic/laws/ConditionalConclusion"
require_relative "../logic/laws/BiconditionalPremise"
require_relative "../logic/laws/BiconditionalConclusion"
require_relative "../logic/laws/ContradictoryConclusion"
require_relative "../logic/laws/SubstituteEquivalents"

class Proof

  attr_reader :proof_tree

  def initialize premise_string, conclusion_string
    constants = (premise_string + conclusion_string).scan(/[\(,]\s?([a-z]{1})/).uniq.flatten.map.with_object({}){|x, hsh| hsh[x] = Constant.new x}
    predicates = (premise_string + conclusion_string).scan(/([A-Z])\(([a-z, ]*)\)/).uniq{|x| x[0]}.map.with_object({}){|x, hsh| hsh[x[0]] = Predicate.new x[0], x[1].split(",").length}
    premise_ary = premise_string.split(/(?<=[) ]),/).map(&:strip).map{|element| parse_string_pc0 element, constants, predicates}
    conclusion = parse_string_pc0 conclusion_string, constants, predicates
    @proof_tree = ProofTree.new [premise_ary, conclusion] 
  end

  def proof
    until @proof_tree.done?
      cur_step = @proof_tree.work_on_step!
      #puts "Proving: Current step is #{cur_step}"
      next_sentence, next_law = yield @proof_tree.get_all_steps, cur_step
      next_law = next_law.new
      step_number_ary = cur_step.step_number.split(".")
      next_major_step_number = step_number_ary[0].to_i + 1

      if next_law.is_a? BranchingLaw
        branch1 = Implication.new cur_step.implication.get_premises, cur_step.implication.get_conclusion
        branch2 = Implication.new cur_step.implication.get_premises, cur_step.implication.get_conclusion
        new_implications = next_law.apply branch1, branch2, next_sentence
        #puts new_implications.map(&:to_s)
        new_implications.each_with_index{|imp, idx| @proof_tree.add_step "#{next_major_step_number}#{("."+step_number_ary[1..-1].join(".") if step_number_ary.length > 1)}.#{idx + 1}", imp, next_law, cur_step}

      else
        new_implication = Implication.new cur_step.get_premises, cur_step.get_conclusion
        new_implication = next_law.apply new_implication, next_sentence
        @proof_tree.add_step "#{next_major_step_number}#{("."+step_number_ary[1..-1].join(".") if step_number_ary.length > 1)}", new_implication, next_law, cur_step
      end

    end
    puts "Success. You proved the implication" if @proof_tree.valid
  end

end
