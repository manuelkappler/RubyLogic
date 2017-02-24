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
  while true
    puts (proof.to_s).yellow
    puts "What implication law do you want to apply? (Type h to see a list of available laws, q to quit, d to mark current branch as done, p to print current state)".cyan
    input = gets.chomp
    if LAWS.include? input
      begin
        proof.add_step input
#      rescue LogicError
#        puts "Can't apply this here".red
      rescue Exception => e
        puts (e.message).light_yellow.on_red
      end
    elsif ["quit", "q"].include? input.downcase
      break
    elsif ["h", "help"].include? input.downcase
      print (LAW_NAMES.join("; ") + "\n").purple
    elsif ["p", "print"].include? input.downcase
      puts "Printing is not yet implemented. Sorry"
    elsif ["d", "done"].include? input.downcase
      puts "Marking as done is not yet implemented"
      break
    end
    if proof.done?
      puts "Done!".green
    end
  end
end

implication = get_initial_implication
create_proof implication
