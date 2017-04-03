class Associativity < Equivalence
  attr_reader :wff
  def initialize wff
    raise LogicError if not associativity? wff
    @original_wff = wff
    @wff = wff
    @connective = wff.connective
    self.apply
  end

  def apply
    wff = @wff
    if wff.element1.is_a? AtomicSentence
      p = wff.element1
      q = wff.element2.element1
      r = wff.element2.element2
      @wff = CompositeSentence.new(@connective, CompositeSentece.new(@connective, p, q), r)
    else
      p = wff.element1.element1
      q = wff.element1.element2
      r = wff.element2
      @wff = CompositeSentence.new(@connective, p, CompositeSentence.new(@connective, q, r))
    end
  end

  def to_latex
    return "#{@original_wff.to_latex} \\equiv #{@wff.to_latex}"
  end

  def to_s
    return "#{@connective.to_s}-Assoc."
  end
end

def associativity? wff
  return false if wff.is_a? AtomicSentence
  return false unless wff.connective.is_a? BinaryConnective 
  begin
    if wff.element1.is_a? AtomicSentence
      conn1 = wff.connective
      conn2 = wff.element2.connective
    elsif wff.element2.is_a? AtomicSentence
      conn1 = wff.element1.connective
      conn2 = wff.connective
    end
    return true if conn1.is_a? conn2.class
  rescue
    return false
  end
  return false
end
