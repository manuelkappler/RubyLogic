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


class SubstituteEquivalents < Law
  @available = true
  @abbrev = "SubEq"

  def self.applies? wff, premise
    possible_equivs = find_equivalences wff
    return possible_equivs if possible_equivs.length > 0
    return false
  end

  def initialize equiv
    @equiv = equiv
  end

  def apply state, wff
    @equiv = @equiv.new wff
    return substitute_equivalents state, wff, @equiv
  end


  def substitute_equivalents state, wff, equiv
    if state.premises.any?{|x| x == wff}
      # puts "Trying to replace premise"
      state.add_premise equiv.wff
      state.delete_premise wff
    else
      # puts "Trying to replace conclusion"
      state.add_conclusion equiv.wff
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

def find_equivalences wff
  return ObjectSpace.each_object(Class).select{|cl| cl < Equivalence}.select{|x| send (x.to_s.downcase + "?").to_sym, wff}
end
