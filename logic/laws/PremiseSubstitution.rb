
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


class PremiseSubstitution < Law

  @available = true
  @abbrev = "SubFree"

  def apply impl, wff
    return premise_substitution impl, wff
  end

  def self.applies? wff, premise
    return false unless premise
    # When does this apply?
    return false
  end

  def premise_substitution impl, wff
    impl.add_premise 
    impl.delete_premise wff
    return impl
  end

  def to_s
    return "Substitute Free Variable"
  end
  def to_latex
    return "(Sub., \\models)"
  end

end
