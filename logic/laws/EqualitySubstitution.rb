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


class LHEqualitySubstitution < Law
  @available = true
  @abbrev = "ESL 1->2"

  def self.to_latex
    return "ESL (a \\Rightarrow b)"
  end

  def self.to_s
    return "ESL: (a to b)"
  end

  def apply state, wff
    @wff = Equality.new(wff.element1, wff.element2)
    @wff.used!
    state.delete_premise wff
    state.add_premise @wff
    return substitute_all state, wff
  end

  def self.applies? wff, premise=true
    return false unless wff.class == Equality
    return true
  end

  def substitute_all state, wff
    from_term, to_term = [wff.element1, wff.element2]
    state.premises.reject{|x| x.class == Equality or x.is_a? Contradiction}.each do |prem|
      state.delete_premise prem
      state.add_premise substitute(prem, from_term, to_term)
    end
    state.add_conclusion substitute(state.conclusion, from_term, to_term) unless state.conclusion.class == Equality or state.conclusion.is_a? Contradiction
    return state
  end

  def substitute wff, term_from, term_to
    if wff.is_a? AtomicSentence
      if wff.class == Equality
        if wff.element1 == term_from
          return Equality.new(term_to, wff.element2)
        else
          return Equality.new(wff.element1, term_to)
        end
      else
        new_sentence = AtomicSentence.new(wff.predicate, wff.constants.map{|x| x == term_from ? term_to : x})
        return new_sentence
      end
    else
      if wff.connective.is_a? Not
        new_sentence = CompositeSentence.new(Not.new, substitute(wff.element1, term_from, term_to))
        return new_sentence
      else
        new_sentence = CompositeSentence.new(wff.connective, substitute(wff.element1, term_from, term_to), substitute(wff.element2, term_from, term_to))
        return new_sentence
      end
    end
  end

  def to_latex
    return "\\text{ESL } (#{@wff.element2} \\text{ for } #{@wff.element1})"
  end

  def to_s
    return "ESL #{@wff.element1} ⇒  #{@wff.element2}"
  end
end

class RHEqualitySubstitution < Law
  @available = true
  @abbrev = "ESL 2->1"

  def self.to_latex
    return "ESL (a \\Rightarrow b)"
  end

  def self.to_s
    return "ESL: (b to a)"
  end

  def apply state, wff
    @wff = Equality.new(wff.element1, wff.element2)
    @wff.used!
    state.delete_premise wff
    state.add_premise @wff
    return substitute_all state, wff
  end

  def self.applies? wff, premise=true
    return false unless wff.class == Equality
    return true
  end

  def substitute_all state, wff
    from_term, to_term = [wff.element2, wff.element1]
    state.premises.reject{|x| x.class == Equality or x.is_a? Contradiction}.each do |prem|
      state.delete_premise prem
      state.add_premise substitute(prem, from_term, to_term)
    end
    state.add_conclusion substitute(state.conclusion, from_term, to_term) unless state.conclusion.class == Equality or state.conclusion.is_a? Contradiction
    return state
  end

  def substitute wff, term_from, term_to
    if wff.is_a? AtomicSentence
      if wff.class == Equality
        if wff.element1 == term_from
          return Equality.new(term_to, wff.element2)
        else
          return Equality.new(wff.element1, term_to)
        end
      else
        new_sentence = AtomicSentence.new(wff.predicate, wff.constants.map{|x| x == term_from ? term_to : x})
        return new_sentence
      end
    else
      if wff.connective.is_a? Not
        new_sentence = CompositeSentence.new(Not.new, substitute(wff.element1, term_from, term_to))
        return new_sentence
      else
        new_sentence = CompositeSentence.new(wff.connective, substitute(wff.element1, term_from, term_to), substitute(wff.element2, term_from, term_to))
        return new_sentence
      end
    end
  end

  def to_latex
    return "\\text{ESL } (#{@wff.element1} \\text{ for } #{@wff.element2})"
  end

  def to_s
    return "ESL #{@wff.element2} ⇒  #{@wff.element1}"
  end


end

