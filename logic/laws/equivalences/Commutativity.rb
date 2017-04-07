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


class Commutativity < Equivalence
  attr_reader :wff

  def initialize wff
    @original_wff = wff
    @wff = wff
    @connective = wff.connective
    self.apply
  end

  def apply
    @wff = CompositeSentence.new(@connective, @wff.element2, @wff.element1)
  end

  def to_s
    return "#{@connective.to_s}-Comm."
  end

  def to_latex
    return "#{@original_wff.to_latex} \\equiv #{@wff.to_latex}"
  end
end

def commutativity? wff
  return false if wff.is_a? AtomicSentence
  return true if wff.connective.is_a? And or wff.connective.is_a? Or
  return false
end
