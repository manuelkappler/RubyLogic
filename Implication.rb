require "./Logic"

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

  def get_premises
    return @premises.clone
  end

  def get_conclusion
    return @conclusion.clone
  end

  def to_s
    return (@premises.map{|x| x.to_s}.join(", ") + " ⊫ " + @conclusion.map{|x| x.to_s}.join(", "))
  end

  def get_vars
    vars = (self.premises.each_with_object([]){|prem, ary| ary << prem.get_vars} | self.conclusion.each_with_object([]){|conc, ary| ary << conc.get_vars}).flatten.uniq
    return vars.each_with_object({}){|var, h| h[var.to_s] = var}
  end


  def add_premise wff
    unless @premises.include? wff
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
    unless @conclusion.include? wff
      @conclusion << wff
    else
      puts "Already present: #{wff.to_s}"
    end
  end

  def delete_conclusion wff
    if @conclusion.any?{|x| x.is_equal? wff}
      @conclusion.each{|x| @conclusion.delete x if x.is_equal? wff}
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

  def conditional_conclusion?
    return true unless @conclusion.select{|x| not x.is_a? Variable and x.connective.is_a? If}.length == 0
    return false
  end

  def disjunction_conclusion?
    return true unless @conclusion.select{|x| not x.is_a? Variable and x.connective.is_a? Or}.length == 0
    return false
  end

  def conjunction_premise?
    return true unless @premises.select{|x| not x.is_a? Variable and x.connective.is_a? And}.length == 0
    return false
  end

  def disjoining?
    return true unless @premises.select{|x| not x.is_a? Variable and x.connective.is_a? If}.length == 0
    return false
  end

  def inconsistent_premises?
    return true if @premises.select{|x| x.is_a? Variable and @premises.select{|y| not y.is_a? Variable and y.connective.is_a? Not and y.atom1 == x}.length > 0}.length > 0
  end

  def premises_include_conclusion?
    return false
  end
end



class LogicError < StandardError
end

class MissingWFFError < LogicError
end
