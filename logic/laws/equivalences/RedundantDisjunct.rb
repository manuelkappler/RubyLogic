class RedundantDisjunct < Equivalence

  attr_reader :wff
  
  def initialize wff
    raise LogicError if not redundantdisjunct? wff
    @original_wff = wff
    @wff = wff
    self.apply
  end

  def apply
    a1 = @wff.element1
    a2 = @wff.element2
    conjunctions = [a1, a2].select{|x| not x.is_a? AtomicSentence and x.connective.is_a? And}
    if conjunctions.length == 1
      @wff = ((conjunctions[0].is_equal? a1) ? a2 : a1)
    else
      # Both are conjunctions, as in (A ∧ B) ∨ ((A ∧ B) ∧ C)
      equals = [a1.element1, a1.element2, a2.element1, a2.element2].select{|x| x.is_equal? a1 or x.is_equal? a2}
      @wff = ((equals[1].is_equal? a1) ? a1 : a2)
    end
  end

  def to_latex
    return "#{@original_wff.to_latex} \\equiv #{@wff.to_latex}"
  end

  def to_s
    return "Redundant Disjunct"
  end
end


def redundantdisjunct? wff
  return false if wff.is_a? AtomicSentence
  return false if wff.connective.is_a? Or
  a1 = wff.element1
  a2 = wff.element2
  begin
    if a1.is_a? AtomicSentence and a2.connective.is_a? And
      return true if (a2.element1.is_equal? a1 or a2.element2.is_equal? a1)
    elsif a2.is_a? AtomicSentence and a1.connective.is_a? And
      return true if a1.element1.is_equal? a2 or a1.element2.is_equal? a2
    else
      return true if ((a2.connective.is_a? And and [a2.element1, a2.element2].any?{|x| x.is_equal? a1}) \
                   or (a1.connective.is_a? And and [a1.element1, a1.element2].any?{|x| x.is_equal? a2}))
    end
  rescue NoMethodError
    return false
  end
  return false
end
