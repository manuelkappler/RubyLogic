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


class Connective
end

class Term

end

class Variable < Term
  def initialize name
    @name = name
  end
  def to_s
    return @name.to_s
  end
end

class Sentence
  def is_equal? other_atom
    if self.class != other_atom.class
      return false
    elsif self.is_a? AtomicSentence and other_atom.is_a? AtomicSentence
      return self.variable == other_atom.variable
    elsif self.is_a? CompositeSentence and other_atom.is_a? CompositeSentence
      if self.connective.is_a? BinaryConnective and other_atom.connective.is_a? BinaryConnective
        return (self.connective.is_a? other_atom.connective.class and self.element1.is_equal? other_atom.element1 and self.element2.is_equal? other_atom.element2)
      elsif self.connective.is_a? UnaryConnective and other_atom.connective.is_a? UnaryConnective
        return (self.connective.is_a? other_atom.connective.class and self.element1.is_equal? other_atom.element1)
      else
        return false
      end
    end
  end

  def get_applicable_laws premise=true
    return ObjectSpace.each_object(Class).select{|cl| cl < Law and cl.available}.select{|law| law.applies? self, premise}
  end

  def <=> other_atom
    return 0 if self == other_atom
    if self.class <= AtomicSentence
      if other_atom.class <= AtomicSentence
        return (self.to_s <=> other_atom.to_s)
      elsif other_atom.is_a? CompositeSentence
        return -1 * (other_atom <=> self)
      end
    elsif self.class <= CompositeSentence
      if self.connective.is_a? Not
        puts "Negated sentence, return comparison for inner element"
        return self.element1 <=> other_atom
      elsif other_atom.class <= CompositeSentence
        if self.connective == other_atom.connective
          return self.element1 <=> other_atom.element1
        else
          return self.connective.sort_priority <=> other_atom.connective.sort_priority
        end
      else 
        return 1
      end
    end
  end

  def == other_atom
    x = self.is_double_negation? ? self.element1.element1 : self
    y = other_atom.is_double_negation? ? other_atom.element1.element1 : other_atom
    if x.class <= AtomicSentence
      if y.class == x.class
        return true if x.predicate == y.predicate and x.terms.map.with_index{|z, idx| z == y.terms[idx]}.all?
      else
        return false
      end
    else
      if y.is_a? CompositeSentence
        return false if x.connective != y.connective
        if x.connective.is_a? UnaryConnective
          return x.element1 == y.element1
        else
          return ((x.element1 == y.element1) and (x.element2 == y.element2))
        end
      end
    end
  end

  def is_double_negation?
    return false unless self.is_a? CompositeSentence
    return false unless self.connective.is_a? Not
    return false unless self.element1.is_a? CompositeSentence
    return true if self.element1.connective.is_a? Not
  end

end

class AtomicSentence < Sentence
  attr_reader :variable

  def initialize variable
    @variable = variable
  end

  def to_s
    return @variable.to_s
  end

  def to_latex
    return @variable.to_s
  end

  def == other
    return @variable.to_s == other.to_s
  end

  def hash
    @variable.to_s.hash
  end

  def eql? other
    return self == other
  end

end

class Contradiction < Sentence

  def initialize
    @symbol = "⊥"
  end

  def to_latex
    return "\\bot"
  end

  def to_s
    return "⊥"
  end

end

class CompositeSentence < Sentence

  attr_reader :connective, :element1, :element2

  def initialize connective, *sentences
    if connective.is_a? BinaryConnective
      @element1 = sentences[0]
      @element2 = sentences[1]
      @connective = connective
    elsif connective.is_a? UnaryConnective
      @element1 = sentences[0]
      @connective = connective
      @element2 = nil
    end
  end

  def to_s
    output(Proc.new{|x| x.to_s})
  end

  def to_latex
    output(Proc.new{|x| x.to_latex})
  end

  def output(procedure)
    if @connective.is_a? BinaryConnective
      if @element1.is_a? CompositeSentence and not @element1.connective.is_a? UnaryConnective
        el1 = "(#{procedure.call(@element1)})"
      else
        el1 = procedure.call(@element1)
      end
      if @element2.is_a? CompositeSentence and not @element2.connective.is_a? UnaryConnective
        el2 = "(#{procedure.call(@element2)})"
      else
        el2 = procedure.call(@element2)
      end
      return "#{el1} #{procedure.call(@connective)} #{el2}"
    else
      if @element1.is_a? CompositeSentence and not @element1.connective.is_a? UnaryConnective
        return "#{procedure.call(@connective)}(#{procedure.call(@element1)})"
      else
        return "#{procedure.call(@connective)}#{procedure.call(@element1)}"
      end
    end
  end

end

# Load all connectives

require_relative "connectives/UnaryConnective"
require_relative "connectives/BinaryConnective"
require_relative "connectives/Connective"
require_relative "connectives/Or"
require_relative "connectives/And"
require_relative "connectives/If"
require_relative "connectives/Iff"
require_relative "connectives/Not"

