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


class Term

  def == other_atom
    return self.to_s == other_atom.to_s
  end

  def <=> other_atom
    return self.to_s <=> other_atom.to_s
  end
end

class Constant < Term

  attr_reader :name

  def initialize string
    @name = string
  end

  def to_s
    return @name
  end

  def to_latex
    return "\\mathit{#{@name}}"
  end

end

class Variable < Term

  def initialize string
    @name = string
  end

  def to_s
    return @name
  end

  def to_latex
    return @name
  end

end

class Predicate

  attr_reader :name, :arity

  def initialize name, arity

    @name = name
    @arity = arity

  end

  def is_valid_extension? args
    return *args.length == @arity
  end

  def to_s
    return @name
  end

  def to_latex
    return @name
  end

  def <=> other_pred
    return @name <=> other_pred.to_s
  end

  def == other_pred
    return true if self.to_s == other_pred.to_s
    return false
  end

  def eql? other_pred
    return true if self.to_s == other_pred.to_s
    return false
  end

  def === other_pred
    return true if self.to_s == other_pred.to_s
    return false
  end

end

class Connective
end

class Sentence

  def get_applicable_laws premise=true
    return ObjectSpace.each_object(Class).select{|cl| cl < Law and cl.available}.select{|law| law.applies? self, premise}
  end

  def substitute variable, constant
    raise LogicError unless (variable.is_a? Variable and constant.is_a? Constant)
    if self.class == AtomicSentence or self.class < AtomicSentence
      if self.class == Equality
        return Equality.new(*self.terms.map{|x| (x.class == Variable and x == variable) ? constant : x})
      else
        return AtomicSentence.new(self.predicate, *self.terms.map{|x| (x.class == Variable and x == variable) ? constant : x})
      end
    elsif self.class == CompositeSentence
      if self.connective.is_a? UnaryConnective
        return CompositeSentence.new(self.connective, self.element1.substitute(variable, constant))
      else
        return CompositeSentence.new(self.connective, self.element1.substitute(variable, constant), self.element2.substitute(variable, constant))
      end
    end
    raise LogicError 
  end

  def get_constants
    if self.class < AtomicSentence or self.class == AtomicSentence
      return self.terms.select{|x| x.class == Constant}
    elsif self.class == CompositeSentence
      if self.connective.is_a? UnaryConnective
        return self.element1.get_constants
      else
        return self.element1.get_constants | self.element2.get_constants
      end
    end
    puts "CRITICAL: End of get_constants method but no value returned"
    raise LogicError
  end

  def get_predicates
    if self.class <= AtomicSentence
      return [self.predicate]
    elsif self.class == CompositeSentence
      if self.connective.is_a? UnaryConnective
        return self.element1.get_predicates
      else
        return self.element1.get_predicates | self.element2.get_predicates
      end
    end
  end

  def <=> other_atom
    return 0 if self == other_atom
    if self.class == Equality
      if other_atom.class == Equality
        return (self.terms[0].to_s <=> other_atom.terms[1].to_s )
      else
        return -1
      end
    elsif self.is_a? AtomicSentence
      if other_atom.is_a? AtomicSentence
        comps = [self.predicate <=> other_atom.predicate] + self.terms.map.with_index{|x, idx| x <=> other_atom.terms[idx]}
        return comps.select{|x| x != 0}[0]
      elsif other_atom.is_a? CompositeSentence
        return 1
        #if other_atom.connective.is_a? UnaryConnective
        #  #return self <=> other_atom.element1
        #else
        #  return [self <=> other_atom.element1, self <=> other_atom.element2].select{|x| x != 0}[0]
        #end
      end
    elsif self.is_a? CompositeSentence
      if other_atom.is_a? CompositeSentence
        if self.connective == other_atom.connective
          return self.element1 <=> other_atom.element1
        else
          return self.connective.sort_priority <=> other_atom.connective.sort_priority
        end
      else
        return 1
      end
      #if self.connective.is_a? UnaryConnective
      #  return self.element1 <=> other_atom
      #else
      #  return [self.element1 <=> other_atom, self.element2 <=> other_atom].select{|x| x != 0}[0]
      #end
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
  attr_reader :predicate, :terms
  def initialize predicate, *terms
    @predicate = predicate
    @terms = []
    if terms.length != predicate.arity
      raise LogicError
    else
      terms.each do |x| 
        if x.is_a? String
          (["u", "v", "w", "x", "y", "z"].include? x) ? @terms << Variable.new(x) : @terms << Constant.new(x)
        elsif x.is_a? Constant or x.is_a? Variable
          @terms << x
        end
      end
    end
  end

  def to_s
    return "#{@predicate.to_s}(#{@terms.map(&:to_s).join(", ")})"
  end

  def to_latex
    return "#{@predicate.to_latex}(#{@terms.map(&:to_s).join(",")})"
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

class Equality < AtomicSentence

  attr_reader :predicate, :terms

  def initialize *terms
    @terms = []
    raise LogicError unless terms.length == 2
    terms.each do |x|
      if x.is_a? String
        (("u".."z").include? x) ? @terms << Variable.new(x) : @terms << Constant.new(x)
      elsif x.is_a? Constant or x.is_a? Variable
        @terms << x
      else
        raise LogicError
      end
    end
    @predicate = Predicate.new("≈", 2)
    @used = false
  end

  def used?
    return @used
  end

  def used!
    @used = true
  end

  def to_latex
    return "#{@terms[0].to_latex} \\approx #{@terms[1].to_latex}"
  end

  def to_s
    return "#{@terms[0].to_s}\\approx #{@terms[1].to_s}"
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
require_relative "connectives/Quantifier"
require_relative "connectives/Universal"
require_relative "connectives/Existential"

#  def is_equal? other_atom
#    if self.class != other_atom.class
#      return false
#    elsif self.is_a? AtomicSentence and self.is_a? other_atom.class
#      return (self.predicate.to_s == other_atom.predicate.to_s and self.terms.map.with_index{|x, idx| true if other_atom.terms[idx].to_s == x.to_s}.all?)
#    elsif (self.is_a? CompositeSentence) and (other_atom.is_a? CompositeSentence)
#      if self.connective.is_a? other_atom.connective.class
#        if self.connective.is_a? UnaryConnective
#          return true if self.element1.is_equal? other_atom.element1
#        else
#          return true if (self.element1.is_equal? other_atom.element1 and self.element2.is_equal? other_atom.element2)
#        end
#      end
#    else
#      raise LogicError
#    end
#  end
