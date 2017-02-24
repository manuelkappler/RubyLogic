require "./LogicParser"
require "./Implication"
require "./Proof"
require 'colorize'

LAW_NAMES = ['Conditional Conclusion (CC)', 'Disjoining (DJ)', 'Monotonicity (MO)', 'Disjunction Conclusion (DC)' , 'Conjunction Premise (CP)']

def get_initial_implication
  vars = {}
  puts "Give me a string (e.g. \"A, A -> B, not C, D or E\") for the premises".cyan
  premises_string = gets.split(",").map{|x| x.strip}
  unless premises_string == [""]
    premises = []
    premises_string.each do |x| 
      vars, x_wff = parse_string(x, vars)
      premises << x_wff
    end 
  else
    premises = []
  end
  # print premises.inspect + "\n"
  puts "Enter the conclusion".cyan
  conclusion_string = gets.chomp
  conclusion_string = conclusion_string.split(",").map{|x| x.strip}
  conclusion = []
  conclusion_string.each do |x| 
    vars, x_wff = parse_string(x, vars)
    conclusion << x_wff
  end 
  # puts conclusion.inspect
  # puts vars.inspect

  return Implication.new premises, conclusion
end

def create_proof implication
  system "clear" or system "cls"
  proof = Proof.new implication
  proof.prove
end

implication = get_initial_implication
create_proof implication
