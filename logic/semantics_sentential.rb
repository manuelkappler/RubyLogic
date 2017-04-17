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


class Interpretation

  def initialize impl, counterexample=false
    @sentences = {}
    if counterexample
      construct_counterexample impl
    end
  end

  def construct_counterexample impl
    raise LogicError if not impl.elementary?
    impl.premises.each do |prem|
      if prem.is_a? AtomicSentence
        @sentences[prem.to_s] = "T"
      else
        @sentences[prem.element1.to_s] = "F"
      end
    end
    if impl.conclusion.is_a? AtomicSentence and not impl.conclusion.is_a? Contradiction
      @sentences[impl.conclusion.to_s] = "F"
    elsif impl.conclusion.is_a? CompositeSentence
      @sentences[impl.conclusion.element1.to_s] = "T"
    end
  end

  def to_latex
    return '\\[' + @sentences.map{|key, value| "#{key} = #{value}"}.sort.join(',') + '\\]'
  end
end

def evaluate connective, *tv
  case connective
  when Not
    return (not tv[0])
  when And
    return (tv[0] and tv[1])
  when Or
    return (tv[0] or tv[1])
  when If
    return (not tv[0] or tv[1])
  when Iff
    return ((not tv[0] or tv[1]) and (not tv[1] or tv[0]))
  end
end
