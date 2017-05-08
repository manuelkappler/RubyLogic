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


class Iff < BinaryConnective

  attr_reader :symbol, :latex, :strings

  def initialize
    @precedence = 5
    @symbol = "↔"
    @latex = "\\leftrightarrow "
    @strings = ["↔", "<->"]
    @sort_priority = 5
  end

end
