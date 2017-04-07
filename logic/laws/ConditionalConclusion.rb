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


class ConditionalConclusion < Law
  @available = true
  @abbrev = "IfCon"

  def apply state, wff
    return conditional_conclusion state, wff
  end

  def self.applies? wff, premise
    return false if premise
    return true if not wff.is_a? AtomicSentence and wff.connective.is_a? If
    return false
  end

  def conditional_conclusion state, wff
    state.add_premise wff.element1
    state.add_conclusion wff.element2
    return state
  end

  def to_s
    return "Cond. Concl."
  end

  def to_latex
    return "(\\models, \\rightarrow)"
  end
end
