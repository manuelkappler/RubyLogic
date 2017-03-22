require_relative 'Implication'
require_relative 'Connectives'
require_relative 'LogicParser'
require 'colorize'
require_relative 'ImplicationLaws'
require 'terminal-table'

class ProofTree

  def initialize given_implication
    law = Given.new
    @root = execute_law(law, given_implication, nil)
    @queue = []
    @queue << @root unless (@root.done? or @root.abort?)
    if @root.done?
      @valid = true
    elsif @root.abort?
      @valid = false
    else
      @valid = nil
    end
    @last_child = @root
  end

  def apply_step law, wff, resolve_ambiguity=nil
    if @queue.empty?
      @valid = true
    else
      current = @queue.shift
      result = execute_law law, current, wff, resolve_ambiguity
      result.each{|res| current.add_child res}
      current.children.each{|child| @queue << child unless (child.done? or child.abort?)}
      (@valid = false; @queue = []; @last_child = current.children.select{|x| x.abort?}[0]) if current.children.any?{|x| x.abort?}
      @valid = true if @queue.empty? and @valid.nil?
    end
  end

  def valid?
    return @valid
  end

  def get_counterexample
    return false if @valid.nil? or @valid
    atoms_prem = @last_child.implication.premises.map{|x| (x.is_a? Variable) ? "#{x.to_s} = T" : "#{x.atom1.to_s} = F"}
    atoms_conc = @last_child.implication.conclusion.reject{|x| x.is_a? Contradiction}.map{|x| (x.is_a? Variable) ? "#{x.to_s} = F" : "#{x.atom1.to_s} = T"}
    atoms = atoms_prem.concat(atoms_conc).uniq
    return atoms.sort.join(", ")
  end

  def get_current_step_wffs
    return nil if @queue.empty? 
    return @queue[0].hash_of_premise_conclusion_wffs
  end

  def get_current_node
    return nil if @queue.empty? 
    return @queue[0]
  end

  def get_applicable_laws_for_wff wff, premise = true
    return {} if wff.is_a? Contradiction
    laws = ObjectSpace.each_object(Class).select{|cl| cl < Law and cl.available}
    if premise
      laws = laws.map.with_object({}){|law, hsh| hsh[law] = law.applies? wff, true}
      return laws
    else
      return laws.map.with_object({}){|law, hsh| hsh[law] = law.applies? wff, false}
    end
  end

  def get_law_from_string string
    laws = ObjectSpace.each_object(Class).select{|cl| cl < Law and cl.available}
    matches = laws.select{|x| x.to_s == string or x.abbrev == string}
    if matches.empty?
      return false
    else
      return matches[0].new
    end
  end

  def execute_law law, node, wff, resolve_ambiguity=nil
    if law.is_a? Given
      return Node.new(node, law, nil, "1")
    elsif law.is_a? BranchingLaw
      next_step = (node.step[0].to_i + 1).to_s + node.step.slice(1..-1)
      new_imp1 = Implication.new node.implication.get_premises, node.implication.get_conclusion
      new_imp2 = Implication.new node.implication.get_premises, node.implication.get_conclusion
      imps = law.apply new_imp1, new_imp2, wff
      new_nodes = imps.map.with_index{|x, idx| Node.new(x, law, node, next_step + ".#{idx + 1}")}
    else
      next_step = (node.step[0].to_i + 1).to_s + node.step.slice(1..-1)
      new_imp = Implication.new node.implication.get_premises, node.implication.get_conclusion
      if resolve_ambiguity.nil?
        new_imp = law.apply new_imp, wff
      else
        new_imp = law.apply new_imp, wff, resolve_ambiguity
      end
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

  def to_latex 
    rows = []
    queue = [@root]
    until queue.empty?
      current = queue.shift
      rows << [current.step, "\\[ #{current.implication.to_latex} \\]", "\\[ #{current.law.to_latex} \\]", (current.done? ? "✔" : (current.abort? ? "✘" : ""))]
      current.children.each{|x| queue << x}
    end
    return rows
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
    @abort = (not @done and @implication.elementary?)
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

  def hash_of_premise_conclusion_wffs
    return {:premises => @implication.get_premises.sort, :conclusion => @implication.get_conclusion.sort}
  end

end
