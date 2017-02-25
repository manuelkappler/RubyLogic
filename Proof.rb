require './Implication'
require './Logic'
require './LogicParser'
require 'colorize'
require './ImplicationLaws'

LAWS = ['Conditional Conclusion', 'CC', 'Disjoining', 'DJ', 'Monotonicity', 'MO', 'Disjunction Conclusion', 'DC', 'Conjunction Premise', 'CP', 'Substitute Equivalents', 'SE']

=begin
  ProofTree
  Node
  | - State
  | - Children

  node1:  implication = law.apply initial_state
          law = law
          children = node2
          done = fales
  node2:  implication = law.apply parent.state
          law = law
          children = node3, node4
          done = false
  node3:  implication = law.apply parent.state
          law = law
          children = node5, node6
          done = false
  node4:  implication = law.apply parent.state
          law = law
          children = nil
          done = true
=end

class ProofTree

  def initialize given_implication
    law = Given.new
    @root = execute_law(law, given_implication)
  end

  def prove
    queue = [@root]
    until queue.empty?
      current = queue.shift
      unless queue.empty? and current.done?
        work_through current
        current.children.each{|x| queue << x unless x.done?}
      end
    end
    self.print
  end


  def work_through node
    next_step = false
    until next_step
      next_step = ask_for_next_step node
      law = get_law_from_string next_step
    end
    (execute_law law, node).each{|x| node.add_child x}
  end

  def ask_for_next_step child
    puts "Working on #{child.to_s}".cyan
    puts "What implication law do you want to apply? (Type h to see a list of available laws, q to quit, d to mark current branch as done, p to print current state)".cyan
    input = gets.chomp
    if ["quit", "q"].include? input.downcase
      exit
    elsif ["h", "help"].include? input.downcase
      print (LAWS.select{|x| x.length > 2}.join("; ") + "\n").magenta
      return false
    elsif ["p", "print"].include? input.downcase
      self.print
      return false
    elsif ["d", "done"].include? input.downcase
      puts "Marking as done is not yet implemented"
      return false
    else
      return input
    end
  end

  def get_law_from_string string
    case string
    when "Conditional Conclusion", "IfCC"
      law = ConditionalConclusion.neww
    when "Conjunction Premise", "CP"
      law = ConjunctionPremise.new
    when "Disjunction Conclusion", "DC"
      law = DisjunctionConclusion.new
    when "Substitution of Equivalents", "SE"
      law = SubstituteEquivalents.new
    when "Disjunction Premise", "DP"
      law = DisjunctionPremise.new
    when "Conjunction Conclusion", "AndCC"
      law = ConjunctionConclusion.new
    else
      return false
    end
    return law
  end

  def execute_law law, node
    if law.is_a? Given
      return Node.new(node, law, nil, "1")
    elsif law.is_a? BranchingLaw
      new_imp1 = Implication.new node.implication.get_premises, node.implication.get_conclusion
      new_imp2 = Implication.new node.implication.get_premises, node.implication.get_conclusion
      imps = law.apply new_imp1, new_imp2
      new_nodes = imps.map.with_index{|x, idx| Node.new(x, law, node, node.step + ".#{idx + 1}")}
    else
      new_imp = Implication.new node.implication.get_premises, node.implication.get_conclusion
      new_imp = law.apply new_imp
      step = "#{node.step.slice(0, node.step.length - 1)}#{node.step[-1].to_i + 1}"
      new_nodes = [Node.new(new_imp, law, node, step)]
    end
    return new_nodes
  end

  def print 
    queue = [@root]
    until queue.empty?
      current = queue.shift
      puts current.to_s
      current.children.each{|x| queue << x}
    end
  end

end

class Node

  attr_reader :implication, :step, :children

  def initialize implication, law, parent, step
    @implication = implication
    @law = law
    @parent = parent
    @children = []
    @step = step
    @done = @implication.trivial?
  end

  def get_previous_implication
    return @parent.implication
  end

  def add_child node
    @children << node
  end
  
  def has_children?
    return (not @children.nil?)
  end

  def get_children
    return @children
  end

  def done?
    return @done
  end

  def to_s 
    return "#{@step} \t #{@implication} \t \t \t #{@law} \t #{"✔" if @done} \n"
  end

end


=begin
class Proof

  def initialize start_implication
    initial_state = State.new start_implication, Given.new
    initial_step = Step.new [initial_state]
    @steps = [initial_step]
  end

  def get_last_step
    return @steps[-1]
  end

  def prove_with_user_input
    while true
      last_step = get_last_step
      last_step.states.each do |state|
        new_step = Step.new
        i = handle_user_input state, gets.chomp
        if i
          begin
            new_step.add_state = apply_law state, i
          rescue LogicError => e
            puts "#{(e.message)}. Can't apply this here.".light_yellow.on_red
          rescue Exception => e
            puts (e.message).light_yellow.on_red
            puts e.backtrace.inspect
          end
        end
      end
#      if self.done?
#        puts "Done!".green
#        break
#      end
    end
  end

  def apply_law prev_state, string
    new_state = Implication.new prev_state.implication.get_premises, prev_state.implication.get_conclusion
    case string
    when "Conditional Conclusion", "IfCC"
      law = ConditionalConclusion.neww
    when "Conjunction Premise", "CP"
      law = ConjunctionPremise.new
    when "Disjunction Conclusion", "DC"
      law = DisjunctionConclusion.new
    when "Substitution of Equivalents", "SE"
      law = SubstituteEquivalents.new
    when "Disjunction Premise", "DP"
      law = DisjunctionPremise.new
    when "Conjunction Conclusion", "AndCC"
      # Implement branching here
    else
      return false
    end
    new_state = (State.new law.apply new_state, law)
    return new_step
  end

  def to_s
    string = ""
    @steps.each_with_index do |step, index|
      string += "#{index} \t #{step.to_s}" + "\t" * ([(32 - step.to_s.length), 4].max / 4) + "#{step.to_s}\n"
    end
    return string
  end

  def done?
    puts @current_step.inspect
    return true if @current_step.state.all?{|implication| implication.trivial?}
    return false
  end

  def handle_user_input input
    puts (self.to_s).yellow
    puts "What implication law do you want to apply? (Type h to see a list of available laws, q to quit, d to mark current branch as done, p to print current state)".cyan
    if ["quit", "q"].include? input.downcase
      return false
    elsif ["h", "help"].include? input.downcase
      print (LAWS.select{|x| x.length > 2}.join("; ") + "\n").magenta
    elsif ["p", "print"].include? input.downcase
      puts "Printing is not yet implemented. Sorry"
      return false
    elsif ["d", "done"].include? input.downcase
      puts "Marking as done is not yet implemented"
      return false
    else
      return input
    end
  end
end

class State
  attr_accessor :implication, :law

  def initialize implication, law
    @law = law
    @implication = implication
  end

  def to_s
    return @implication.to_s
  end

end

class Step

  def initialize
    @states = []
  end

  def add_state state
    @states << state
  end

end
=end
