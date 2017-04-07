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


class ConjunctionConclusion < BranchingLaw
  @available = true
  @abbrev = "AndCon"

  def apply imp1, imp2, wff
    return conjunction_conclusion imp1, imp2, wff
  end

  def self.applies? wff, premise
    return false if premise
    return true if not wff.is_a? AtomicSentence and wff.connective.is_a? And
    return false
  end

  def conjunction_conclusion imp1, imp2, wff
    imp1.add_conclusion wff.element1
    imp2.add_conclusion wff.element2
    return [imp1, imp2]
  end

  def to_s
    return "(⊧, ∧)"
  end
  def to_latex
    return "(\\models, \\wedge)"
  end
end
