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
      puts "Checking whether elementary premises"
      if Object.const_defined?('Equality')
        if @premises.any?{|x| x.class == Equality and not x.used?}
          return false
        end
        puts "No unused equalities"
      end
      if Object.const_defined?('Universal')
	if @premises.any?{|x| x.is_a? CompositeSentence and x.connective.is_a? Universal and ((not x.connective.has_been_applied?) or (not self.get_all_constants.all?{|y| x.connective.has_been_applied? y}))}
          return false
        end
        puts "No unused quantifiers"
      end
    rescue Exception => e
      puts "Error in checking for elementary conclusion. #{e.message}"
    end
    return true if @premises.reject{|wff| 
      Object.const_defined?('Universal') and wff.is_a? CompositeSentence and wff.connective.is_a? Universal and self.get_all_constants.all?{|y| wff.connective.has_been_applied? y}}.all?{|x| x.is_a? AtomicSentence or
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
    puts "Adding premise #{wff} to #{@premises.inspect}"
    unless @premises.any?{|x| x == wff}
      if @premises.empty?
        @premises = [wff]
      else
        @premises << wff
      end
    else
      puts "Already present"
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
      @premises.delete_if{|x| x == wff}
    rescue Exception => e
      puts "Error when deleting #{wff} from #{@premises}"
      @premises.each{|x| puts "#{wff} == #{x}? #{(wff == x).inspect}"}
      puts "Caught error #{e.message}. #{e.backtrace}"
      raise MissingWFFError
    end
  end

  def inconsistent_premises?
    return true if @premises.any?{|x| puts "Checking for contradictions with #{x}: "; @premises.any? {|y| if x == CompositeSentence.new(Not.new, y) then puts "#{x} == ¬#{y}!"; true else false end}}
    puts "No inconsistent premises found, checking for applications of negated self-identity"
    if Object.const_defined?('Equality')
      return true if @premises.any?{|x| x.is_a? CompositeSentence and x.element1.is_a? Equality and x.connective.is_a? Not and x.element1.terms[0] == x.element1.terms[1]}
      return false
    end
  end

  def premises_contain_conclusion?
    return false if @conclusion.is_a? Contradiction
    puts "Checking for equality with conclusions"
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
    puts "Calling get_constants for each of #{@premises}"
    @premises.each{|x| x.get_constants.each{|y| consts << y}}
    @conclusion.get_constants.each{|x| consts << x} unless @conclusion.is_a? Contradiction
    return consts.uniq{|x| x.name}
  end



end



class LogicError < StandardError
end

class MissingWFFError < LogicError
end
