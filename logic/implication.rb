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
    #puts "Checking whether to abort. Current claim is trivial? #{trivial?}. Current claim is elementary? #{elementary?}"
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
    rescue
    end
    return true if @premises.all?{|x| x.is_a? AtomicSentence or (x.is_a? CompositeSentence and x.connective.is_a? Not and x.element1.is_a? AtomicSentence)} and (@conclusion.is_a? AtomicSentence or @conclusion.is_a? Contradiction or (@conclusion.is_a? CompositeSentence and @conclusion.connective.is_a? Not and @conclusion.element1.is_a? AtomicSentence))
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
    puts "#{@premises.map{|x| x.to_s}.join(',')}\n #{@premises.sort.map{|x| x.to_s}.join(',')}"
    return (@premises.sort.map{|x| x.to_latex}.join(", ") + " \\models " + @conclusion.to_latex)
  end

  def get_vars
    vars = (self.premises.each_with_object([]){|prem, ary| ary << prem.get_vars} | self.conclusion.each_with_object([]){|conc, ary| ary << conc.get_vars}).flatten.uniq
    return vars.each_with_object({}){|var, h| h[var.to_s] = var}
  end


  def add_premise wff
    #puts "Adding premise #{wff.inspect}"
    unless @premises.any?{|x| x.is_equal? wff}
      if @premises == [nil]
        @premises = [wff]
      else
        @premises << wff
      end
      #puts @premises
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
    return true if @premises.any?{|x| @premises.any? {|y| CompositeSentence.new(Not.new, x).is_equal? y}}
    return false
  end

  def premises_contain_conclusion?
    return true if @premises.any? {|x| x.is_equal? @conclusion}
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
end



class LogicError < StandardError
end

class MissingWFFError < LogicError
end
