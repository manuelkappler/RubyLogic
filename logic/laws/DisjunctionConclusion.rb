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


class DisjunctionConclusion < Law

  @available = true
  @abbrev = "OrCon"

  def apply state, wff
    return disjunction_conclusion state, wff
  end

  def self.applies? wff, premise
    return false if premise
    return true if not wff.is_a? AtomicSentence and wff.connective.is_a? Or
    return false
  end

  def disjunction_conclusion state, wff

    new_wff = CompositeSentence.new(Not.new, wff.element1)
    state.add_premise new_wff
    state.add_conclusion wff.element2
    return state
  end
  def to_s
    return "(⊧, ∨)"
  end

  def to_latex
    return "(\\models, \\vee)"
  end

end
