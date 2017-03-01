require './Implication'
require './Connectives'
require './LogicParser'
require 'colorize'
require './ImplicationLaws'
require 'terminal-table'

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
        self.print
        current.children.each{|x| queue << x unless x.done?}
      end
    end
  end


  def work_through node
    next_step = false
    until next_step
      law = false
      while not law
        next_step = ask_for_next_step node
        law = get_law_from_string next_step
      end
    end
    begin
      (execute_law law, node).each{|x| node.add_child x}
    rescue LogicError => e
      puts "This can't be done".on_light_red
      puts e.message
      work_through node
    end
  end

  def ask_for_next_step child
    puts "Working on #{child.to_s}".cyan
    puts "What implication law do you want to apply? (Type h to see a list of available laws, q to quit, d to mark current branch as done, p to print current state)".cyan
    input = gets.chomp
    if ["quit", "q"].include? input.downcase
      exit
    elsif ["h", "help"].include? input.downcase
      print_all_available_laws (child.implication)
      return false
    elsif ["p", "print"].include? input.downcase
      self.print
      return false
    elsif ["d", "done"].include? input.downcase
      child.mark_as_aborted
      self.print
      exit
    else
      return input
    end
  end

  def get_all_available_laws state
    return ObjectSpace.each_object(Class).select{|cl| cl < Law and cl.available}
    # TODO: Implement rejecting any laws that can't be applied in current state
  end

  def print_all_available_laws state
    get_all_available_laws(state).each{|l| puts "#{l.to_s} (#{l.abbrev})"}
  end

  def get_law_from_string string
    laws = ObjectSpace.each_object(Class).select{|cl| cl < Law and cl.available}
    matches = laws.select{|x| x.to_s == string or x.abbrev == string}
    if matches.empty?
      puts "Can't find that law. Try again or enter 'h' to see a list of all the laws I can apply"
      return false
    else
      return matches[0].new
    end
#    case string
#    when "Conditional Conclusion", "IfCC"
#      law = ConditionalConclusion.new
#    when "Conjunction Premise", "CP"
#      law = ConjunctionPremise.new
#    when "Disjunction Conclusion", "DC"
#      law = DisjunctionConclusion.new
#    when "Substitution of Equivalents", "SE"
#      law = SubstituteEquivalents.new
#    when "Disjunction Premise", "DP"
#      law = DisjunctionPremise.new
#    when "Conjunction Conclusion", "AndCC"
#      law = ConjunctionConclusion.new
#    when "Monotonicity", "MO"
#      law = Monotonicity.new
#    when "Disjoining", "DJ"
#      law = Disjoining.new
#    when "Reverse Conjunction Premise", "RCP"
#      law = ReverseConjunctionPremise.new
#    else
#      return false
#    end
#    return law
  end

  def execute_law law, node
    if law.is_a? Given
      return Node.new(node, law, nil, "1")
    elsif law.is_a? BranchingLaw
      next_step = (node.step[0].to_i + 1).to_s + node.step.slice(1..-1)
      new_imp1 = Implication.new node.implication.get_premises, node.implication.get_conclusion
      new_imp2 = Implication.new node.implication.get_premises, node.implication.get_conclusion
      imps = law.apply new_imp1, new_imp2
      new_nodes = imps.map.with_index{|x, idx| Node.new(x, law, node, next_step + ".#{idx + 1}")}
    else
      next_step = (node.step[0].to_i + 1).to_s + node.step.slice(1..-1)
      new_imp = Implication.new node.implication.get_premises, node.implication.get_conclusion
      new_imp = law.apply new_imp
      new_nodes = [Node.new(new_imp, law, node, next_step)]
    end
    return new_nodes
  end

  def print 
    header = ["Step", "Implication", "Applied Laws", "✔"]
    rows = []
    queue = [@root]
    until queue.empty?
      current = queue.shift
      rows << [current.step, current.implication, current.law, (current.done? ? "✔" : ("✕" if current.abort?))]
      current.children.each{|x| queue << x}
    end
    table = Terminal::Table.new :rows => rows, :headings => header
    puts table
  end

end

class Node

  attr_reader :implication, :step, :children, :law

  def initialize implication, law, parent, step
    @implication = implication
    @law = law
    @parent = parent
    @children = []
    @step = step
    @done = @implication.trivial?
    @abort = false
  end

  def get_previous_implication
    return @parent.implication
  end

  def mark_as_aborted
    @abort = true
  end

  def abort?
    return true if @abort
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
