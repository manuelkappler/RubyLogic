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


def parse_string_fol input_string, constants_hsh, predicates_hsh
  puts "Called parse_string_pc0 with #{input_string}"
  return Contradiction.new if input_string == "⊥" or input_string == "Contradiction"
  # If the whole string is merely an equality, take care of it now
  if /\A(?<a>[a-z])\s?(≈|eq)\s?(?<b>[a-z])\z/ =~ input_string
    return Equality.new(a, b)
  end
  neg, disj, conj, cond, bicond, paren = [Not.new, Or.new, And.new, If.new, Iff.new, LeftParenthesis.new]
  operators = {"not" => neg, "¬" => neg, "or" => disj, "∨" => disj, "∧" => conj, "and" => conj, "->" => cond, "<->" => bicond, "→" => cond, "↔" => bicond, "(" => paren}
  premise_queue = OutputQueue.new
  operator_stack = [Sentinel.new]
  puts "Input string #{input_string}"
  # Key to regex:
  # ([A-Z]\([a-z,\s]\) splits predicates P(a, b) etc.
  # (?<![a-z])\) splits at close parens that don't immediately follow a term
  # (?<![A-Z)\( splits at open parens that don't immediately follow a predicate
  # (?<=[q≈]\s[a-z])\) splits at close parens that immediately follow an equality
  # remaining split at connectives
  regex = /\s*([A-Z]\([a-z,\s]\)|(?<![a-z])\)|(?<![A-Z])\(|(?<=[q≈]\s[a-z])\)|and|or|->|→|↔|<->|not|¬|∧|∨|exists\s[a-z]|∃\s?[a-z]|all\s[a-z]|∀\s?[a-z])\s*/
  puts "Split with new regex, the string becomes: #{input_string.split(regex)}"
  # old_regex = /\s*(and|or|->|<->|∧|∨|→|↔|¬|not|(?<![a-z])\)|(?<![A-Z])\((?=\s?[a-z])|(?<=[eq|≈][\s|][a-z])\)|all\s[a-z]|exists\s[a-z]|∀[a-z]|∃[a-z])\s*/
  input_string.split(regex).each do |element|
    print "Current operator stack: #{operator_stack.map(&:to_s)}\n"
    print "Current premise queue: #{premise_queue.map(&:to_s)}\n"
    print "Working on: #{element}\n"
    if element == ")"
      puts "Close paren"
      until operator_stack[-1].is_a? LeftParenthesis or operator_stack[-1].is_a? Sentinel
        premise_queue << operator_stack.pop
      end
      if operator_stack[-1].is_a? Sentinel
        raise MismatchedParenthesis
      else
        operator_stack.pop
      end
    elsif ["and","or","->", "<->","∧","∨", "→", "↔"].include? element or ["not", "¬"].include? element
      puts "Operator"
      while (not operator_stack[-1].is_a? Sentinel) and operator_stack[-1] > operators[element]
        premise_queue << operator_stack.pop
      end
      operator_stack << operators[element]
    elsif element == "("
      puts "Open paren"
      operator_stack << operators[element]
    elsif element.strip == ""
      puts "Empty element, skipping"
    elsif /(?<q>(all|exists|∀|∃))\s?(?<v>[a-z])/ =~ element
      puts "Parsing a quantifier #{q}, found variable #{v}"
      if q == "all" or q == "∀"
        operator_stack << Universal.new(Variable.new(v))
      elsif q == "exists" or q == "∃"
        operator_stack << Existential.new(Variable.new(v))
      else
        raise LogicError
      end
    elsif /\A(?<a>[a-z])\s?(eq|≈)\s?(?<b>[a-z])/ =~ element
      puts "New equality between #{a} and #{b}"
      begin
        eq = Equality.new(a, b)
        puts eq.inspect
        premise_queue <<  eq
      rescue Exception => e
        puts "An #{e.to_s} exception occurred in parse_string, equality branch of parsing: #{e.backtrace}"
        raise LogicError
      end
    else
      puts "Element #{element}"
      raise ParsingError unless predicates_hsh.has_key? element[0]
      pred = predicates_hsh[element[0]]
      vars = element.scan(/.*?([a-z]{1}).*?/).flatten
      premise_queue << AtomicSentence.new(pred, *vars)
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
    puts "get_wff called for #{self.inspect}"
    puts "#{self.map{|x| x.class}}"
    if self[-1].is_a? BinaryConnective
      op = self.pop
      a2 = self.get_wff
      a1 = self.get_wff
      return CompositeSentence.new(op, a1, a2)
#      return WFF.new(self.get_wff, op, self.get_wff)
    elsif self[-1].is_a? UnaryConnective and not self[-1].is_a? EqualityDummy
      op = self.pop
      puts "#{op}"
      return CompositeSentence.new(op, self.get_wff)
    elsif self[-1].is_a? Quantifier
      op = self.pop
      puts "Popping quants #{op}"
      return CompositeSentence.new(op, self.get_wff)
    else
      puts "In else"
      return self.pop
    end
  end

end

class Sentinel < Connective
  def initialize
    @precedence = 10
  end
  def to_s
    return "S"
  end
end

class EqualityDummy < Connective
  def initialize
    @precedence = 0
  end
  def to_s
    return "≈"
  end
end

class LeftParenthesis < Connective
  def initialize
    @precedence = 9
  end
  def to_s
    return "("
  end
end

class MismatchedParenthesis < StandardError
end

class ParsingError < StandardError
end
