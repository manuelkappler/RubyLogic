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

class Given < Law
  @available = false

  def apply state, wff=nil
    return state
  end
  def to_s
    return "Given"
  end
  def self.to_latex
    return "(Given)"
  end
  def to_latex
    return "(Given)"
  end
end
