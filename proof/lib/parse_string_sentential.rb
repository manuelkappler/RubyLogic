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


def parse_string_sentential input_string, variable_hsh
  #puts input_string
  neg, disj, conj, cond, bicond, paren = [Not.new, Or.new, And.new, If.new, Iff.new, LeftParenthesis.new]
  operators = {"not" => neg, "¬" => neg, "or" => disj, "∨" => disj, "∧" => conj, "and" => conj, "->" => cond, "<->" => bicond, "→" => cond, "↔" => bicond, "(" => paren} 
  premise_queue = OutputQueue.new
  operator_stack = [Sentinel.new]
  input_string.split(/\s*(and|or|->|<->|∧|∨|→|↔|¬|not|\(|\))\s*/).each do |element|
    #print "Current operator stack: #{operator_stack.map(&:to_s)}\n"
    #print "Current premise queue: #{premise_queue.map(&:to_s)}\n"
    #print "Working on: #{element}\n"
    if element == ")"
      until operator_stack[-1].is_a? LeftParenthesis or operator_stack[-1].is_a? Sentinel
        premise_queue << operator_stack.pop
      end
      operator_stack.pop
    elsif ["and","or","->", "<->","∧","∨", "→", "↔"].include? element or ["not", "¬"].include? element
      while (not operator_stack[-1].is_a? Sentinel) and operator_stack[-1] > operators[element]
        premise_queue << operator_stack.pop
      end
      operator_stack << operators[element]
    elsif element == "("
      operator_stack << operators[element]
    elsif element == ""
    else
      var = variable_hsh[element[0]]
      premise_queue << AtomicSentence.new(var)
    end
  end
  until operator_stack[-1].is_a? Sentinel
    x = operator_stack.pop
    if x.is_a? LeftParenthesis
      raise MismatchedParenthesis
    else
      premise_queue << x
    end
  end
  return premise_queue.get_wff
end

class OutputQueue < Array

  def get_wff
    if self[-1].is_a? BinaryConnective
      op = self.pop
      a2 = self.get_wff
      a1 = self.get_wff
      return CompositeSentence.new(op, a1, a2)
#      return WFF.new(self.get_wff, op, self.get_wff)
    elsif self[-1].is_a? UnaryConnective and not self[-1].is_a? EqualityDummy
      op = self.pop
      return CompositeSentence.new(op, self.get_wff)
    else
      return self.pop
    end
  end

end

class Sentinel < UnaryConnective
  def initialize
    @precedence = 10
  end
  def to_s
    return "S"
  end
end

class EqualityDummy < UnaryConnective
  def initialize
    @precedence = 0
  end
  def to_s
    return "≈"
  end
end

class LeftParenthesis < UnaryConnective
  def initialize
    @precedence = 9
  end
  def to_s
    return "("
  end
end
