class ProofTree

  attr_reader :queue, :root, :valid

  def initialize given_claim
    # given_claim is array of: an array of premises and a (single) conclusion [[pre1, pre2, pre3], conclusion]
    @root = Step.new("1", Implication.new(given_claim[0], given_claim[1]), Given, nil)
    if @root.implication.done? 
      @valid = true
    elsif @root.implication.abort?
      @valid = false
    else
      @valid = nil
    end
    @queue = (@root.implication.done? or @root.implication.abort?) ? [] : [@root]
  end

  def done?
    return true if @valid or @abort
  end

  def add_step step_number, implication, law, parent
    step = Step.new step_number, implication, law, parent
    parent.add_child step
    @queue << step unless (step.implication.done? or step.implication.abort?)
    @valid = false if step.implication.abort?
    @valid = true if @queue.empty? and @valid.nil?
    #puts "Added step #{step_number}. @valid is now #{@valid}"
  end

  def get_current_step
    return @queue[0]
  end

  def work_on_step!
    #puts "in work_on_step! asking for next queue element"
    el = @queue.shift
    #puts "returning #{el}"
    return el
  end

  def get_all_steps
    #return "To be implemented"
    return traverse_tree @root
  end

  def traverse_tree node
    ary = [node]
    node.children.each{|c| queue << c}
    until queue.empty?
      next_el = queue.shift
      ary << next_el
      next_el.children.each{|c| queue << c}
    end
    return ary
  end


  class Step 
    attr_reader :step_number, :implication, :law, :parent, :children

    def initialize step_number, implication, law, parent
      @step_number = step_number
      @implication = implication
      @law = law
      @parent = parent
      @children = []
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

  end

end
