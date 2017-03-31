class ProofTree

  attr_reader :queue, :root, :valid, :counterexample

  def initialize given_claim
    # given_claim is array of: an array of premises and a (single) conclusion [[pre1, pre2, pre3], conclusion]
    @root = Step.new("1", Implication.new(given_claim[0], given_claim[1]), Given, nil)
    if @root.valid? 
      @valid = 1
    elsif @root.abort?
      puts "#{@root} is aborted"
      @counterexample = construct_counterexample @root.implication
      @valid = -1
    else
      @valid = 0
    end
    @queue = (@root.valid? or @root.abort?) ? [] : [@root]
    #puts "Queue initialized. Currently: #{@queue}"
  end

  def check_all_branches
    puts "Checking all branches for aborts or all branches done..."
    puts "========================================================"
    ary = traverse_tree @root
    puts "total number of steps: #{ary.length}"
    puts "Steps that have ABORT flag: #{ary.select{|x| x.abort?}.length}"
    puts "Steps that have VALID flag: #{ary.select{|x| x.valid?}.length}"
    if ary.any?{|x| x.abort?} 
      @counterexample = construct_counterexample ary.select{|x| x.abort?}[0].implication
      puts "Setting @valid to -1"
      @valid = -1 
    elsif ary.select{|x| x.children.empty?}.any?{|x| not x.valid?}
      puts "Setting @valid to 0"
      @valid = 0
    else
      puts "Setting @valid to 1"
      @valid = 1
    end
  end

  def add_step step_number, implication, law, parent
    step = Step.new step_number, implication, law, parent
    parent.add_child step
    #puts "Adding #{step} to #{@queue}"; 
    @queue << step unless (step.valid? or step.abort?)
  end

  def construct_counterexample impl
    puts "In construct_counterexample for implication #{impl.inspect}"
    return false unless impl.elementary?
    return nil if impl.valid?
    predicates = (impl.premises + [impl.conclusion]).reject{|x| x.class == Equality or x.is_a? Contradiction}.map{|x| (x.is_a? AtomicSentence) ? x.predicate : x.element1.predicate}.flatten
    puts predicates
    constants = (impl.premises + [impl.conclusion]).map{|x| (x.is_a? AtomicSentence)  ? x.constants : x.element1.constants unless x.is_a? Contradiction}.flatten
    puts constants
    int = Interpretation.new predicates, constants
    impl.premises.each do |prem|
      if prem.is_a? CompositeSentence 
        if prem.element1.class == Equality
        else
          raise LogicError unless prem.connective.is_a? Not
          int.set_predicate prem.element1.predicate, false, prem.element1.constants
        end
      elsif prem.class == Equality
        int.add_equality prem
      elsif prem.is_a? AtomicSentence
        int.set_predicate prem.predicate, true, prem.constants
      end
    end
    unless impl.conclusion.is_a? Contradiction
      if impl.conclusion.is_a? CompositeSentence
        raise LogicError unless impl.conclusion.connective.is_a? Not
        int.set_predicate impl.conclusion.element1.predicate, true, impl.conclusion.element1.constants
      else
        int.set_predicate impl.conclusion.predicate, false, impl.conclusion.constants
      end
    end
    return int
  end

  def get_current_step
    return @queue[0]
  end

  def work_on_step!
    #puts "in work_on_step! asking for next queue element, which is #{@queue[0]}"
    return @queue.shift unless @valid != 0
    #puts "returning #{el}"
  end

  def get_all_steps
    #return "To be implemented"
    return traverse_tree @root
  end

  def traverse_tree node
    ary = [node]
    queue = []
    node.children.each{|c| queue << c}
    until queue.empty?
      next_el = queue.shift
      ary << next_el
      next_el.children.each{|c| queue << c}
    end
    return ary
  end

  def to_latex
    traverse_node(@root).map{|step| [step.step_number, "\\[ #{step.implication.to_latex} \\]", "\\[ #{step.law.to_latex} \\]", (step.valid? ? "✔" : (step.abort? ? "✘" : ""))]}
  end

  class Step 
    attr_reader :step_number, :implication, :law, :parent, :children

    def initialize step_number, implication, law, parent
      @step_number = step_number
      @implication = implication
      @law = law
      @parent = parent
      @valid = implication.valid?
      @abort = implication.abort?
      @children = []
    end

    def valid?
      return @valid
    end

    def abort?
      return @abort
    end

    def get_premises
      return @implication.get_premises
    end

    def get_conclusion
      return @implication.get_conclusion
    end

    def add_child step
      @children << step 
    end

    def to_s
      return "#{@step_number}: #{@implication.to_s} (#{@law.to_s}) #{"Checkmark" if @implication.valid?}"
    end

    def to_latex
      return "#{@step_number}: #{@implication.to_latex} (#{@law.to_latex}) #{"Check" if @implication.valid?}"
    end

  end

end
