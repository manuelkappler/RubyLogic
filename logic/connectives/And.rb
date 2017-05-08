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


class And < BinaryConnective

  attr_reader :latex, :strings, :symbol

  def initialize
    @precedence = 2
    @symbol = "∧"
    @strings = ["and", "∧"]
    @latex = "\\wedge "
    @sort_priority = 6
  end

end
