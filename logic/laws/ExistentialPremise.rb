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


class ExistentialPremise < Law
  @available = true
  @abbrev = "EPrem"


  def initialize constant
    @constant = constant
  end

  def apply state, wff
    return existential_premise state, wff
  end

  def self.applies? wff, premise
    return false if not premise
    return true if (not wff.is_a? AtomicSentence) and wff.connective.is_a? Existential
    return false
  end

  def existential_premise state, wff
    state.delete_premise wff
    state.add_premise wff.element1.substitute(wff.connective.variable, @constant)
    return state
  end

  def to_s
    return "∃, ||= #{@constant}"
  end

  def to_latex
    return "(\\exists, \\models) #{@constant}"
  end
end
