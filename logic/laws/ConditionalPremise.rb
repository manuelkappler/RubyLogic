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


class ConditionalPremise < BranchingLaw

  @available = true
  @abbrev = "IfPre"

  def self.applies? wff, premise
    return false unless premise
    return true if (not wff.is_a? AtomicSentence) and wff.connective.is_a? If
    return false
  end

  def apply imp1, imp2, wff
    return condprem imp1, imp2, wff
  end

  def condprem imp1, imp2, wff
    if not wff.element1.is_a? AtomicSentence and wff.element1.connective.is_a? Not
      # Deal with double negation
      imp1.add_premise wff.element1.element1
      imp1.delete_premise wff
    else
      imp1.add_premise CompositeSentence.new(Not.new, wff.element1) 
      imp1.delete_premise wff
    end
    imp2.add_premise wff.element2
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
