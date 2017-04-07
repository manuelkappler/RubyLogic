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


require_relative "../../proof/proof_pc0.rb"

test_string_prem, test_string_conc = ["L(y, x) → H(x), L(x, y), L(x, y) → L(y, x)", "H(x)"]

p = Proof.new test_string_prem, test_string_conc

p.proof do |all_steps, cur_step|
  puts all_steps
  all_elements = cur_step.implication.premises + [cur_step.implication.conclusion]
  puts "-------" * 5
  puts "Choose the element to work on"
  element_chosen = false
  while not element_chosen
    all_elements.each_with_index{|el, idx| puts "[#{idx}]: #{el.to_s}"}
    element = all_elements[gets.chomp.to_i]
    puts "You chose #{element.to_s}. Correct (Y/N)?"
    if ["y", "yes"].include? gets.chomp.downcase
      element_chosen = true
    end
  end
  if cur_step.implication.premises.include? element
    laws = element.get_applicable_laws true
  end
  if cur_step.implication.conclusion.is_equal? element
    #puts "Checking for conclusion laws"
    #puts element.inspect
    laws = element.get_applicable_laws false
  end
  law_chosen = false
  while not law_chosen
    puts "Choose the law to apply"
    laws.each_with_index{|l, idx| puts "[#{idx}]: #{l.to_s}"}
    law = laws[gets.chomp.to_i] 
    puts "You chose #{law.to_s}. Correct (Y/N)?"
    if ["y", "yes"].include? gets.chomp.downcase
      law_chosen = true
    end
  end
  [element, law]
end
if p.proof_tree.valid
  puts "==================================="
  puts "=========== VALID ================="
  puts "==================================="
  puts p.proof_tree.get_all_steps
else
  puts "==================================="
  puts "=========== INVALID================"
  puts "==================================="
  puts "Counterexamples not yet implemented"
end
