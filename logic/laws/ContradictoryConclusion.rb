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


class ContradictoryConclusion < Law

  @available = true
  @abbrev = "CC"

  def self.applies? wff, premise
    premise ? (return false) : (return true)
  end

  def apply state, wff
    if wff.is_a? CompositeSentence and wff.connective.is_a? Not
      state.add_premise wff.element1
    else
      state.add_premise CompositeSentence.new(Not.new, wff)
    end
    state.add_conclusion Contradiction.new
    return state
  end

  def to_s
    return "CC"
  end

  def to_latex
    return "(\\models, \\bot)"
  end

end
