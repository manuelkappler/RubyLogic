require './Implication'
require './Connectives'
require './LogicParser'
require 'colorize'
require './ImplicationLaws'

LAWS = ['Conditional Conclusion', 'CC', 'Disjoining', 'DJ', 'Monotonicity', 'MO', 'Disjunction Conclusion', 'DC', 'Conjunction Premise', 'CP', 'Substitute Equivalents', 'SE']


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
      law = ConditionalConclusion.new
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
    when "Monotonicity", "MO"
      law = Monotonicity.new
    when "Disjoining", "DJ"
      law = Disjoining.new
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
