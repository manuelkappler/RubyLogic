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


class Connective
  include Comparable

  attr_reader(:precedence)

  def to_s
    return @symbol
  end

  def to_latex
    return @latex
  end

  def <=>(other_connective)
    raise ArgumentError unless other_connective.is_a? Connective
    if self.precedence < other_connective.precedence
      return 1
    elsif self.precedence > other_connective.precedence
      return -1
    else
      return 0
    end
  end
end
