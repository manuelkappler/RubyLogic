class Idempotence < Equivalence
  attr_reader :wff

  def initialize wff
    raise LogicError if not idempotence? wff
    @connective = wff.connective
    @original_wff = wff
    @wff = wff
    self.apply
  end

  def apply
    @wff = @wff.element1
  end

  def to_s
    return "#{@connective}-Idempotence"
  end

  def to_latex
    return "#{@original_wff.to_latex} \\equiv #{@wff.to_latex}"
  end
end

def idempotence? wff
  return false if wff.is_unary?
  begin
    return true if wff.connective.is_a? And or wff.connective.is_a? Or and wff.element1.is_equal? wff.element2
    return false
  rescue Exception => e
    puts e.message
    return false
  end
end
