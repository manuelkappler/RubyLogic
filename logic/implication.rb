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

require 'set'

class Implication

  attr_accessor :premises, :conclusion

  def initialize premises_ary, conclusion
    @premises = premises_ary
    @conclusion = conclusion
  end

  def done?
    return true if trivial? or elementary?
    return false
  end

  def abort?
    return true if elementary? and not trivial?
    return false
  end

  def trivial?
    return true if (self.inconsistent_premises? or self.premises_contain_conclusion? or self.eq1?)
    return false
  end

  def valid?
    return true if trivial?
    return false
  end

  def elementary?
    begin
      if @premises.any?{|x| x.class == Equality and not x.used?}
        return false
      end
      if @premises.any?{|x| x.class == Universal and not self.get_all_constants{|y| x.connective.has_been_applied? y}}
        return false
      end
    rescue
    end
    return true if @premises.reject{|wff| 
      wff.is_a? CompositeSentence and wff.connective.is_a? Universal and 
        self.get_all_constants.all?{|y| wff.connective.has_been_applied? y}}.all?{|x| 
        x.is_a? AtomicSentence or
          (x.is_a? CompositeSentence and x.connective.is_a? Not and x.element1.is_a? AtomicSentence)} and 
      (@conclusion.is_a? AtomicSentence or 
       @conclusion.is_a? Contradiction or 
       (@conclusion.is_a? CompositeSentence and @conclusion.connective.is_a? Not and @conclusion.element1.is_a? AtomicSentence))
    return false
  end
                                                        

  def get_premises
    return @premises.clone
  end
  def get_conclusion
    return @conclusion.clone
  end

  def to_s
    return (@premises.sort.map{|x| x.to_s}.join(", ") + " ⊧ " + @conclusion.to_s)
  end
  
  def to_latex
    return (@premises.sort.map{|x| x.to_latex}.join(", ") + " \\models " + @conclusion.to_latex)
  end

  def get_vars
    vars = (self.premises.each_with_object([]){|prem, ary| ary << prem.get_vars} | self.conclusion.each_with_object([]){|conc, ary| ary << conc.get_vars}).flatten.uniq
    return vars.each_with_object({}){|var, h| h[var.to_s] = var}
  end


  def add_premise wff
    unless @premises.any?{|x| x == wff}
      if @premises == [nil]
        @premises = [wff]
      else
        @premises << wff
      end
    else
    end
  end

  def add_conclusion wff
    @conclusion = wff
  end

  def delete_conclusion wff
    begin
      @conclusion = nil
    rescue
      raise MissingWFFError
    end
  end

  def delete_premise wff
    begin
      @premises.delete wff
    rescue
      raise MissingWFFError
    end
  end

  def inconsistent_premises?
    return true if @premises.any?{|x| @premises.any? {|y| negated = CompositeSentence.new(Not.new, x); puts "Testing whether \n\t #{negated} (#{negated.inspect}) and \n\t #{y} (#{y.inspect}) are contradictions}"; negated == y}}
    return true if @premises.any?{|x| x.is_a? CompositeSentence and x.element1.is_a? Equality and x.connective.is_a? Not and x.element1.terms[0] == x.element1.terms[1]}
    return false
  end

  def premises_contain_conclusion?
    return true if @premises.any? {|x| x == @conclusion}
    return false
  end

  def eq1?
    begin
      return true if @premises.any? {|x| x.is_a? CompositeSentence and x.connective.is_a? Not and x.element1.class == Equality and (x.element1.element1 == x.element1.element2)}
      return false
    rescue
      return false
    end
  end

  def get_all_constants
    consts = []
    @premises.each{|x| x.get_constants.each{|y| consts << y}}
    @conclusion.get_constants.each{|x| consts << x} unless @conclusion.is_a? Contradiction
    return consts.uniq{|x| x.name}
  end



end



class LogicError < StandardError
end

class MissingWFFError < LogicError
end
