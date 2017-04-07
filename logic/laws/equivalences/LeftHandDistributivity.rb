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


class LeftHandDistributivity < Equivalence
  attr_reader :wff

  # p x (q y r) = (p x q) y (p x r)
  def initialize wff
    @original_wff = wff
    @wff = wff
    @handedness = "LH"
    self.apply
  end

  def apply
  # p x (q y r) = (p x q) y (p x r)
    major_connective = @wff.connective
    minor_connective = @wff.element2.connective
    p = @wff.element1
    q = @wff.element2.element1
    r = @wff.element2.element2
    @wff = CompositeSentence.new(minor_connective, CompositeSentence.new(major_connective, p, q), CompositeSentence.new(major_connective, p, r))
    @version = major_connective
  end

  def to_latex
    return "#{@original_wff.to_latex} \\equiv #{@wff.to_latex}"
  end

  def to_s
    return "#{@handedness == "RH" ? 'Right-hand' : 'Left-hand'} #{@version.to_s}-Distr."
  end
end

def lefthanddistributivity? wff
  return false if wff.is_a? AtomicSentence
  # p x (q y r) = (p x q) y (p x r)
  begin
    # puts "Checking for LH-Distr. at #{wff.to_s}"
    # Main connective must be AND or OR
    return false unless wff.connective.is_a? And or wff.connective.is_a? Or
    main_connective = wff.connective
    minor_connective = (main_connective.is_a? And) ? Or : And
    # puts "Step 1: #{main_connective.to_s} => #{minor_connective.to_s}"
    # The second atom must be the opposite connective
    return false if wff.element2.is_a? AtomicSentence
    return false unless wff.element2.connective.is_a? minor_connective
    # puts "Step 2"
    return true
  rescue Exception => e
    puts e.message
    return false
  end
end
