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
require 'pry'

class Model

  def initialize impl = nil, counterexample = false
    @universe = Set.new
    @predicates = Set.new
    @constants = Set.new
    @variables = Set.new
    unless impl.nil?
      impl.premises.each{|x| x.get_predicates.each{|y| @predicates << y}}
      impl.conclusion.get_predicates.each{|x| @predicates << x} unless impl.conclusion.is_a? Contradiction
    end
    @pi_hash = @predicates.map.with_object({}){|pred, hsh| hsh[pred] = Set.new}
    @equalities = []
    @inequalities = []
    unless not counterexample or impl.nil?
      construct_counterexample impl
    end
  end

  class PartOfUniverse
    def initialize name
      @name = name
    end
  end

  def create_universe *members
    members.map{|x| PartOfUniverse.new(x)}.each{|y| @universe << y}
  end

  def add_predicate pred
    return false unless @predicates[pred].nil?
    @predicates[pred] = Set.new
  end

  def add_to_extension pred, *ext
    raise LogicError unless pred.is_a? Predicate
    if @predicates[pred].nil?
      add_predicate pred
    end
    raise LogicError unless pred.is_valid_extension? ext
    @predicates[pred] << ext
  end

  def add_variable var
    raise LogicError unless var.is_a? Variable
    @variables << var
  end

  def add_constant const, reference
    raise LogicError unless const.is_a? Constant
    raise LogicError unless @universe.includes? reference
    @constants[const] = reference
  end

  def construct_counterexample implication
    implication.premises.each do |prem|
      if prem.is_a? CompositeSentence 
        if prem.element1.class == Equality
        elsif prem.connective.class == Universal
        else
          raise LogicError unless prem.connective.is_a? Not
          self.set_predicate prem.element1.predicate, false, prem.element1.terms
        end
      elsif prem.class == Equality
        self.add_equality prem
      elsif prem.is_a? AtomicSentence
        self.set_predicate prem.predicate, true, prem.terms
      end
    end
    unless implication.conclusion.is_a? Contradiction
      if implication.conclusion.is_a? CompositeSentence
        raise LogicError unless implication.conclusion.connective.is_a? Not
        self.set_predicate implication.conclusion.element1.predicate, true, implication.conclusion.element1.terms
      else
        self.set_predicate implication.conclusion.predicate, false, implication.conclusion.terms
      end
    end
  end

  def set_predicate predicate, boolean, terms
    begin
      if boolean
        @pi_hash[predicate] << terms 
      end
    rescue Exception => e
      puts "Exception in set_predicate while constructing counterexample. #{e.message}\n\n#{e.backtrace}"
    end
  end

  def add_equality eq
    @equalities << eq
    update_inequalities
  end

  def update_inequalities
    ineq = []
    @constants.each do |const1|
      @constants.each do |const2|
        if const1 == "" or const1.nil? or const2 == "" or const2.nil?
          next
        elsif const1 == const2
          next
        elsif @equalities.any?{|x| (x.element1 == const1 and x.element2 == const2) or (x.element2 == const1 and x.element1 == const2)}
          next
        elsif ineq.any?{|x| (x.element1 == const1 and x.element2 == const2) or (x.element2 == const1 and x.element1 == const2)}
          next
        else
          ineq << Equality.new(const1, const2)
        end
      end
    end
    @inequalities = ineq
  end


  def pi predicate, element
    return @pi_hash[predicate].include? element
  end

  def to_s
    delta_string = @equalities.map{|x| "\\delta(#{x.element1}) = \\delta(#{x.element2})"}.join(", ") + "\\\\" + @inequalities.map{|x| "\\delta(#{x.element1}) \\neq \\delta(#{x.element2})"}.join(", ")
    pi_string = @pi_hash.map{|pred, ext| "π(#{pred}) = {#{ext.empty? ? "∅" : ext.map{|e| '('+ e.map{|d| 'δ(' + d.to_s + ')'}.join(',') + ')'}.join(',')}}"}.join("\n")
    return delta_string + "\n" + pi_string
  end

  def to_latex
    delta_string = '\\[' + @equalities.map{|x| a, b = [x.element1, x.element2].map(&:to_s).sort; "\\delta(#{a}) = \\delta(#{b})"}.join(", ") + '\\] \\[' + @inequalities.map{|x| a, b = [x.element1, x.element2].map(&:to_s).sort; "\\delta(#{a}) \\neq \\delta(#{b})"}.join(", ") + '\\]'
    pi_string = '\\[' + @pi_hash.map{|pred, ext| "\\pi(#{pred}) = #{ext.empty? ? '\\varnothing' : ('\\{' + ext.map{|e| '('+ e.map{|d| '\\delta(' + d.to_s + ')'}.join(',') + ')'}.join(',') + '\\}')}"}.join("\\] \\[") + '\\]'

    return delta_string + pi_string 
  end

end
