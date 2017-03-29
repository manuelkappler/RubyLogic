class Implication

  attr_accessor :premises, :conclusion

  def initialize premises_ary, conclusion
    @premises = premises_ary
    @conclusion = conclusion
  end

  def done?
    return true if trivial? or elementary?
    return false
  end

  def abort?
    puts "Checking whether to abort. Current claim is trivial? #{trivial?}. Current claim is elementary? #{elementary?}"
    return true if elementary? and not trivial?
    return false
  end

  def trivial?
    return true if (self.inconsistent_premises? or self.premises_contain_conclusion?)
    return false
  end

  def valid?
    return true if trivial?
    return false
  end

  def elementary?
    return true if @premises.all?{|x| x.is_a? AtomicSentence or (x.is_a? CompositeSentence and x.connective.is_a? Not and x.element1.is_a? AtomicSentence)} and (@conclusion.is_a? AtomicSentence or @conclusion.is_a? Contradiction or (@conclusion.is_a? CompositeSentence and @conclusion.connective.is_a? Not and @conclusion.element1.is_a? AtomicSentence))
    return false
  end
                                                        

  def get_premises
    return @premises.clone
  end

  def get_conclusion
    return @conclusion.clone
  end

  def to_s
    return (@premises.map{|x| x.to_s}.sort.join(", ") + " ⊧ " + @conclusion.to_s)
  end
  
  def to_latex
    return (@premises.map{|x| x.to_latex}.sort.join(", ") + " \\models " + @conclusion.to_latex)
  end

  def get_vars
    vars = (self.premises.each_with_object([]){|prem, ary| ary << prem.get_vars} | self.conclusion.each_with_object([]){|conc, ary| ary << conc.get_vars}).flatten.uniq
    return vars.each_with_object({}){|var, h| h[var.to_s] = var}
  end


  def add_premise wff
    #puts "Adding premise #{wff.inspect}"
    unless @premises.any?{|x| x.is_equal? wff}
      if @premises == [nil]
        @premises = [wff]
      else
        @premises << wff
      end
      #puts @premises
    else
      puts "Already present: #{wff.to_s}"
    end
  end

  def add_conclusion wff
    @conclusion = wff
  end

  def delete_conclusion wff
    begin
      @conclusion = nil
    rescue
      raise MissingWFFError
    end
  end

  def delete_premise wff
    begin
      @premises.delete wff
    rescue
      raise MissingWFFError
    end
  end

  def disjunction_premise?
    return true if @premises.any?{|x| not x.is_a? AtomicSentence and x.connective.is_a? Or}
    return false
  end

  def conditional_conclusion?
    return true if @conclusion.any?{|x| not x.is_a? AtomicSentence and x.connective.is_a? If}
    return false
  end

  def disjunction_conclusion?
    return true if @conclusion.any?{|x| not x.is_a? AtomicSentence and x.connective.is_a? Or}
    return false
  end

  def conjunction_premise?
    return true if @premises.any?{|x| not x.is_a? AtomicSentence and x.connective.is_a? And}
    return false
  end

  def reverse_conjunction_premise?
    return true if @premises.length > 1
    return false
  end

  def conjunction_conclusion?
    return true if @conclusion.any?{|x| not x.is_a? AtomicSentence and x.connective.is_a? And}
    return false
  end

  def disjoining?
    return true if @premises.any?{|x| not x.is_a? AtomicSentence and x.connective.is_a? If and @premises.any?{|y| y.is_equal? x.element1}}
    return false
  end

  def inconsistent_premises?
    return true if @premises.any?{|x| @premises.any? {|y| CompositeSentence.new(Not.new, x).is_equal? y}}
    return false
  end

  def premises_contain_conclusion?
    return true if @premises.any? {|x| x.is_equal? @conclusion}
    return false
  end
end



class LogicError < StandardError
end

class MissingWFFError < LogicError
end
