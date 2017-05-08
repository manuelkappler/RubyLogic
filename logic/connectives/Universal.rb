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


class Universal < Quantifier

  attr_reader :symbol, :latex, :strings, :variable

  def initialize variable=nil
    puts "ALERT: Universal initialized with no variable" if variable.nil? 
    @symbol = "∀"
    @precedence = 2
    @latex = "\\forall"
    @strings = ["all", "∀"]
    @variable = variable
    @sort_priority = 1
    @used = []
  end

  def mark_used_for_constant const
    @used << const
  end

  def has_been_applied? const
    return @used.include? const
  end


  def to_s
    return "#{@symbol}#{@variable}"
  end

  def to_latex
    return "#{@latex} #{@variable}"
  end

end
