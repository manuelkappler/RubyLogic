# RubyLogic is a Sinatra-based Web App that enables students to play
# around with proving claims in Sentential and Predicate logic following
# the system laid out by Haim Gaifman.
# 
# Copyright (C) 2017 Manuel Käppler, manuel.kaeppler@columbia.edu
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.


class FOLProof

  attr_reader :proof_tree

  def initialize premise_string, conclusion_string

    puts "Created new PC0Proof"

    # Load syntax and semantics
    load File::expand_path('../logic/syntax_fol.rb')
    load File::expand_path("../logic/semantics_fol.rb")

    # Load helper functions: the ProofTree class which keeps track of the proof, and parse_string which turns strings into an Implication claim
    # 

    load File::expand_path('../proof/lib/ProofTree.rb')
    load File::expand_path('../proof/lib/parse_string_fol.rb')

    # Load the implication helper class

    load File::expand_path('../logic/implication.rb')

    # Load DeMorgan equivalences (no other equivalence laws needed or used)

    load File::expand_path("../logic/laws/equivalences/Equivalence.rb")
    load File::expand_path("../logic/laws/equivalences/DeMorgan.rb")

    # Load all Implication Laws for pc0

    load File::expand_path("../logic/laws/Law.rb")
    load File::expand_path("../logic/laws/BranchingLaw.rb")
    load File::expand_path("../logic/laws/Given.rb")
    load File::expand_path("../logic/laws/ConjunctionPremise.rb")
    load File::expand_path("../logic/laws/ConjunctionConclusion.rb")
    load File::expand_path("../logic/laws/DisjunctionPremise.rb")
    load File::expand_path("../logic/laws/DisjunctionConclusion.rb")
    load File::expand_path("../logic/laws/ConditionalPremise.rb")
    load File::expand_path("../logic/laws/ConditionalConclusion.rb")
    load File::expand_path("../logic/laws/BiconditionalPremise.rb")
    load File::expand_path("../logic/laws/BiconditionalConclusion.rb")
    load File::expand_path("../logic/laws/ContradictoryConclusion.rb")
    load File::expand_path("../logic/laws/SubstituteEquivalents.rb")
    load File::expand_path("../logic/laws/EqualitySubstitution.rb")
    load File::expand_path("../logic/laws/UniversalPremise.rb")
    load File::expand_path("../logic/laws/ExistentialPremise.rb")

    puts "Trying to parse #{premise_string} and #{conclusion_string}"
    constants = (premise_string + conclusion_string).scan(/[a-z]{1}/).uniq.flatten.map.with_object({}){|x, hsh| hsh[x] = Constant.new x}
    predicates = (premise_string + conclusion_string).scan(/([A-Z])\(([a-z, ]*)\)/).uniq{|x| x[0]}.map.with_object({}){|x, hsh| hsh[x[0]] = Predicate.new(x[0], x[1].split(",").length)}
    premise_ary = premise_string.split(/(?<=[) ]),|(?<=[≈]\s[a-z]),|(?<=[eq]\s[a-z]),/).map(&:strip).map{|element| parse_string_fol element, constants, predicates}
    conclusion = parse_string_fol conclusion_string, constants, predicates
    @proof_tree = ProofTree.new [premise_ary, conclusion] 
  end

  def valid?
    done = @proof_tree.valid
    x= (done == -1) ? false : (done == 1) ? true : nil
    return x
  end

  def get_counterexample
    return @proof_tree.counterexample
  end

  def next_step!
    @current_step = @proof_tree.work_on_step!
    @all_steps = @proof_tree.get_all_steps
    return [@all_steps, @current_step]
  end

  def apply_step! next_sentence, next_law
    cur_step = @current_step
    step_number_ary = cur_step.step_number.split(".")
    next_major_step_number = step_number_ary[0].to_i + 1

    if next_law.is_a? BranchingLaw
      branch1 = Implication.new cur_step.implication.get_premises, cur_step.implication.get_conclusion
      branch2 = Implication.new cur_step.implication.get_premises, cur_step.implication.get_conclusion
      new_implications = next_law.apply branch1, branch2, next_sentence
      new_implications.each_with_index{|imp, idx| @proof_tree.add_step "#{next_major_step_number}#{("."+step_number_ary[1..-1].join(".") if step_number_ary.length > 1)}.#{idx + 1}", imp, next_law, cur_step}

    else
      new_implication = Implication.new cur_step.get_premises, cur_step.get_conclusion
      new_implication = next_law.apply new_implication, next_sentence
      @proof_tree.add_step "#{next_major_step_number}#{("."+step_number_ary[1..-1].join(".") if step_number_ary.length > 1)}", new_implication, next_law, cur_step
    end
    @proof_tree.check_all_branches
  end


  def proof
    until @proof_tree.done?
      cur_step = @proof_tree.work_on_step!
      next_sentence, next_law = yield @proof_tree.get_all_steps, cur_step
      next_law = next_law.new
      step_number_ary = cur_step.step_number.split(".")
      next_major_step_number = step_number_ary[0].to_i + 1

      if next_law.is_a? BranchingLaw
        branch1 = Implication.new cur_step.implication.get_premises, cur_step.implication.get_conclusion
        branch2 = Implication.new cur_step.implication.get_premises, cur_step.implication.get_conclusion
        new_implications = next_law.apply branch1, branch2, next_sentence
        new_implications.each_with_index{|imp, idx| @proof_tree.add_step "#{next_major_step_number}#{("."+step_number_ary[1..-1].join(".") if step_number_ary.length > 1)}.#{idx + 1}", imp, next_law, cur_step}

      else
        new_implication = Implication.new cur_step.get_premises, cur_step.get_conclusion
        new_implication = next_law.apply new_implication, next_sentence
        @proof_tree.add_step "#{next_major_step_number}#{("."+step_number_ary[1..-1].join(".") if step_number_ary.length > 1)}", new_implication, next_law, cur_step
      end

    end

  end

  def to_latex
    x = @proof_tree.to_latex
    return x
  end
end
