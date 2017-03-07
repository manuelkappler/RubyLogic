require_relative "Connectives"

# Implemented Implication laws
# Conditional conclusion
# Disjoining
# Monotonicity

class Implication

  attr_accessor :premises, :conclusion

  def initialize premises_ary, conclusion_ary
    @premises = premises_ary
    @conclusion = conclusion_ary
  end

  def trivial?
    return true if (self.inconsistent_premises? or self.premises_contain_conclusion?)
    return false
  end

  def get_premises
    return @premises.clone
  end

  def get_conclusion
    return @conclusion.clone
  end

  def to_s
    return (@premises.map{|x| x.to_s}.sort.join(", ") + " ⊧ " + @conclusion.map{|x| x.to_s}.sort.join(", "))
  end
  
  def to_latex
    return (@premises.map{|x| x.to_latex}.sort.join(", ") + " \\models " + @conclusion.map{|x| x.to_latex}.sort.join(", "))
  end

  def get_vars
    vars = (self.premises.each_with_object([]){|prem, ary| ary << prem.get_vars} | self.conclusion.each_with_object([]){|conc, ary| ary << conc.get_vars}).flatten.uniq
    return vars.each_with_object({}){|var, h| h[var.to_s] = var}
  end


  def add_premise wff
    unless @premises.any?{|x| x.is_equal? wff}
      if @premises == [nil]
        @premises = [wff]
      else
        @premises << wff
      end
    else
      puts "Already present: #{wff.to_s}"
    end
  end

  def add_conclusion wff
    unless @conclusion.any?{|x| x.is_equal? wff}
      @conclusion << wff
    else
      puts "Already present: #{wff.to_s}"
    end
  end

  def delete_conclusion wff
    if @conclusion.any?{|x| x.is_equal? wff}
      @conclusion.reject!{|x| x.is_equal? wff}
    else
      raise MissingWFFError
    end
  end

  def delete_premise wff
    if @premises.any?{|x| x.is_equal? wff}
      @premises.each{|x| @premises.delete x if x.is_equal? wff}
    else
      raise MissingWFFError
    end
  end

  def disjunction_premise?
    return true if @premises.any?{|x| not x.is_a? Variable and x.connective.is_a? Or}
    return false
  end

  def conditional_conclusion?
    return true if @conclusion.any?{|x| not x.is_a? Variable and x.connective.is_a? If}
    return false
  end

  def disjunction_conclusion?
    return true if @conclusion.any?{|x| not x.is_a? Variable and x.connective.is_a? Or}
    return false
  end

  def conjunction_premise?
    return true if @premises.any?{|x| not x.is_a? Variable and x.connective.is_a? And}
    return false
  end

  def reverse_conjunction_premise?
    return true if @premises.length > 1
    return false
  end

  def conjunction_conclusion?
    return true if @conclusion.any?{|x| not x.is_a? Variable and x.connective.is_a? And}
    return false
  end

  def disjoining?
    return true if @premises.any?{|x| not x.is_a? Variable and x.connective.is_a? If and @premises.any?{|y| y.is_equal? x.atom1}}
    return false
  end

  def inconsistent_premises?
    return true if @premises.any?{|x| @premises.any? {|y| WFF.new(x, Not.new).is_equal? y}}
    return false
  end

  def premises_contain_conclusion?
    return true if @conclusion.all?{|x| @premises.any? {|y| x.is_equal? y}}
    return false
  end
end



class LogicError < StandardError
end

class MissingWFFError < LogicError
end
