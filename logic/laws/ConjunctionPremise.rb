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


class ConjunctionPremise < Law
  @available = true
  @abbrev = "ConPre"
  def apply state, wff
    return conjunction_premise state, wff
  end

  def self.applies? wff, premise
    return false unless premise
    return true if not wff.is_a? AtomicSentence and wff.connective.is_a? And
    return false
  end

  def conjunction_premise state, wff
    puts "Deleting #{wff}"
    state.delete_premise wff
    puts "Adding #{wff.element1}"
    state.add_premise wff.element1
    puts "Adding #{wff.element2}"
    state.add_premise wff.element2
    return state
  end
  def to_s
    return "(∧, ⊧)"
  end
  def to_latex
    return "(\\wedge, \\models)"
  end
end
