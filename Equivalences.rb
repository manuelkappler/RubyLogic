require "./Connectives"

class Equivalence
end

class DeMorgan < Equivalence

  attr_reader :wff

  def initialize wff
    @wff = wff
    @connective = wff.atom1.connective
    self.apply
  end

  def apply
    cur_wff = self.wff
    inside = cur_wff.atom1
    neg = Not.new
    if @connective.is_a? And
      @wff = WFF.new(WFF.new(inside.atom1, neg), Or.new, WFF.new(inside.atom2, neg))
    elsif @connective.is_a? Or
      @wff = WFF.new(WFF.new(inside.atom1, neg), And.new, WFF.new(inside.atom2, neg))
    end
  end

  def to_s
    return "#{@connective.to_s}-DM"
  end
end

def demorgan? wff
  begin
    return true if wff.connective.is_a? Not and (wff.atom1.connective.is_a? And or wff.atom1.connective.is_a? Or)
    return false
  rescue
    return false
  end
end

class Commutativity < Equivalence
  attr_reader :wff

  def initialize wff
    @wff = wff
    @connective = wff.connective
    self.apply
  end

  def apply
    @wff = WFF.new(@wff.atom2, @connective, @wff.atom1)
  end

  def to_s
    return "#{@connective.to_s}-Comm."
  end
end

def commutativity? wff
  return true if wff.connective.is_a? And or wff.connective.is_a? Or
  return false
end

class Associativity < Equivalence
  attr_reader :wff
  def initialize wff
    raise LogicError if not associativity? wff
    @wff = wff
    @connective = wff.connective
    self.apply
  end

  def apply
    wff = @wff
    if wff.atom1.is_unary?
      @wff = WFF.new(WFF.new(wff.atom1, @connective, wff.atom2.atom1), @connective, wff.atom2.atom2)
    else
      @wff = WFF.new(wff.atom1.atom1, @connective, WFF.new(wff.atom1.atom2, @connective, wff.atom2))
    end
  end

  def to_s
    return "#{@connective.to_s}-Assoc."
  end
end

def associativity? wff
  return false unless wff.connective.is_a? BinaryConnective 
  begin
    if wff.atom1.is_unary?
      conn1 = wff.connective
      conn2 = wff.atom2.connective
      return true if conn1.is_a? conn2.class
    elsif
      wff.atom2.is_unary?
      conn1 = wff.atom1.connective
      conn2 = wff.connective
    end
    return true if conn1.is_a? conn2.class
  rescue
    return false
  end
  return false
end

class DoubleNegation < Equivalence
  attr_reader :wff

  def initialize wff
    @wff = wff
    self.apply
  end

  def apply
    @wff = @wff.atom1.atom1
  end

  def to_s
    return "DN"
  end
end

def doublenegation? wff
  begin
    return true if wff.atom1.is_unary? and wff.atom1.atom1.is_unary? and wff.connective.is_a? Not and wff.atom1.connective.is_a? Not
  rescue
    return false
  end
  return false
end

class Distributivity < Equivalence
  attr_reader :wff

  def initialize wff
    raise LogicError unless distributivity? wff
    @wff = wff
    self.apply
  end

  def apply
    unary_atoms = [@wff.atom1, @wff.atom2].select{|x| x.is_unary?}
    if unary_atoms.length == 0
      distributee = resolve_ambiguities [@wff.atom1, @wff.atom2], "distribute over other expression"
      distributand = (@wff.atom1 == distributee ? @wff.atom2 : @wff.atom1)
    elsif unary_atoms.length == 1
      distributee = unary_atoms[0]
      distributand = (@wff.atom1 == distributee ? @wff.atom2 : @wff.atom1)
    end
    major_connective = @wff.connective
    minor_connective = distributand.connective
    p = distributee
    q = distributand.atom1
    r = distributand.atom2
    @handedness = (p.is_equal? @wff.atom1) ? "LH" : "RH"
    @wff = WFF.new(WFF.new(p, major_connective, q), minor_connective, WFF.new(p, major_connective, r))
    @version = major_connective
  end

  def to_s
    return "#{@handedness == "RH" ? 'Right-hand' : 'Left-hand'} #{@version.to_s}-Distr."
  end
end

def distributivity? wff
  begin
    # Main connective must be AND or OR
    return false unless wff.connective.is_a? And or wff.connective.is_a? Or
    # One of the two atoms must be the opposite connective
    return false unless [wff.atom1, wff.atom2].any?{|x| not x.is_unary? and x.connective.is_a? ((wff.connective.is_a? And) ? Or : And)}
    return true
  rescue Exception => e
    puts e.message
    return false
  end
end

class ReverseDistributivity < Equivalence
  attr_reader :wff

  def initialize wff
    raise LogicError unless reversedistributivity? wff
    @wff = wff
    self.apply
  end 

  def apply
    major_connective = @wff.atom1.connective
    minor_connective = @wff.connective
    if @wff.atom1.atom1.is_equal? @wff.atom2.atom1
      p = @wff.atom1.atom1
      q = @wff.atom1.atom2 
      r = @wff.atom2.atom2
    else
      p = @wff.atom1.atom2
      q = @wff.atom1.atom1
      r = @wff.atom2.atom1
    end
    @version = major_connective
    @wff = WFF.new(p, major_connective, WFF.new(q, minor_connective, r))
  end

  def to_s
    return "#{@version.to_s} - Distributivity"
  end

end

def reversedistributivity? wff
  begin
    # Main connective must be AND or OR
    return false unless wff.connective.is_a? And or wff.connective.is_a? Or
    # Both atoms must be the opposite connective
    return false unless [wff.atom1, wff.atom2].all?{|x| not x.is_unary? and x.connective.is_a? ((wff.connective.is_a? And) ? Or : And)}
    # One atom.atom must be the same in each of the atoms 
    return false unless wff.atom1.atom1.is_equal? wff.atom2.atom1 or wff.atom1.atom2.is_equal? wff.atom2.atom2
    return true
  rescue Exception => e
    puts e.message
    return false
  end
end

class Idempotence < Equivalence
  attr_reader :wff

  def initialize wff
    raise LogicError if not idempotence? wff
    @connective = wff.connective
    @wff = wff
    self.apply
  end

  def apply
    @wff = @wff.atom1
  end

  def to_s
    return "#{@connective}-Idempotence"
  end
end

def idempotence? wff
  begin
    return true if wff.connective.is_a? And or wff.connective.is_a? Or and wff.atom1.is_equal? wff.atom2
    return false
  rescue Exception => e
    puts e.message
    return false
  end
end

class RedundantDisjunct < Equivalence

  attr_reader :wff
  
  def initialize wff
    raise LogicError if not redundantdisjunct? wff
    @wff = wff
    self.apply
  end

  def apply
    a1 = @wff.atom1
    a2 = @wff.atom2
    conjunctions = [a1, a2].select{|x| not x.is_unary? and x.connective.is_a? And}
    if conjunctions.length == 1
      @wff = ((conjunctions[0].is_equal? a1) ? a2 : a1)
    else
      # Both are conjunctions, as in (A ∧ B) ∨ ((A ∧ B) ∧ C)
      equals = [a1.atom1, a1.atom2, a2.atom1, a2.atom2].select{|x| x.is_equal? a1 or x.is_equal? a2}
      @wff = ((equals[1].is_equal? a1) ? a1 : a2)
    end
  end

  def to_s
    return "Redundant Disjunct"
  end
end


def redundantdisjunct? wff
  unless wff.connective.is_a? Or
    return false
  end
  a1 = wff.atom1
  a2 = wff.atom2
  begin
    if a1.is_unary? and a2.connective.is_a? And
      return true if (a2.atom1.is_equal? a1 or a2.atom2.is_equal? a1)
    elsif a2.is_unary? and a1.connective.is_a? And
      return true if a1.atom1.is_equal? a2 or a1.atom2.is_equal? a2
    else
      return true if ((a2.connective.is_a? And and [a2.atom1, a2.atom2].any?{|x| x.is_equal? a1}) \
                   or (a1.connective.is_a? And and [a1.atom1, a1.atom2].any?{|x| x.is_equal? a2}))
    end
  rescue NoMethodError
    return false
  end
  return false
end

class RedundantConjunct < Equivalence
  attr_reader :wff
  
  def initialize wff
    raise LogicError if not redundantconjunct? wff
    @wff = wff
    self.apply
  end

  def apply
    a1 = @wff.atom1
    a2 = @wff.atom2
    disjunctions = [a1, a2].select{|x| not x.is_unary? and x.connective.is_a? Or}
    if disjunctions.length == 1
      @wff = ((disjunctions[0].is_equal? a1) ? a2 : a1)
    else
      # Both are disjunctions, as in (A ∨ B) ∨ ((A ∧ B) ∧ C)
      equals = [a1.atom1, a1.atom2, a2.atom1, a2.atom2].select{|x| x.is_equal? a1 or x.is_equal? a2}
      @wff = ((equals[1].is_equal? a1) ? a1 : a2)
    end
  end

  def to_s
    return "Redundant Conjunct"
  end
end

def redundantconjunct? wff
  unless wff.connective.is_a? And
    return false
  end
  a1 = wff.atom1
  a2 = wff.atom2
  begin
    if a1.is_unary? and a2.connective.is_a? Or
      return true if (a2.atom1.is_equal? a1 or a2.atom2.is_equal? a1)
    elsif a2.is_unary? and a1.connective.is_a? Or 
      return true if a1.atom1.is_equal? a2 or a1.atom2.is_equal? a2
    else
      return true if ((a2.connective.is_a? Or and [a2.atom1, a2.atom2].any?{|x| x.is_equal? a1}) \
                   or (a1.connective.is_a? Or and [a1.atom1, a1.atom2].any?{|x| x.is_equal? a2}))
    end
  rescue NoMethodError
    return false
  end
  return false
end

class If2Or < Equivalence
  attr_reader :wff
  def initialize wff
    raise LogicError unless if2or? wff
    @wff = wff
    self.apply
  end
  def apply
    neg = Not.new
    disj = Or.new
    @wff = WFF.new(WFF.new(@wff.atom1, neg), disj, @wff.atom2)
  end

  def to_s
    return "If-Definition"
  end
end

def if2or? wff
  return true if wff.connective.is_a? If
  return false
end

class Contrapositive < Equivalence
  attr_reader :wff
  def initialize wff
    raise LogicError unless contrapositive? wff
    @wff = wff
    self.apply
  end

  def apply
    neg = Not.new
    @wff = WFF.new(WFF.new(@wff.atom2, neg), If.new, WFF.new(@wff.atom1, neg))
  end

  def to_s
    return "Contrapositive"
  end
end

def contrapositive? wff
  return true if wff.connective.is_a? If
  return false
end

class Iff2Or < Equivalence
  attr_reader :wff
  def initialize wff
    raise LogicError unless iff2or? wff
    @wff = wff
    self.apply
  end
  def apply
    conj = And.new
    neg = Not.new
    disj = Or.new
    @wff = WFF.new(WFF.new(@wff.atom1, conj, @wff.atom2), disj, WFF.new(WFF.new(@wff.atom1, neg), conj, WFF.new(@wff.atom2, neg)))
  end
  def to_s
    "Iff-Definition"
  end
end

def iff2or? wff
  return true if wff.connective.is_a? Iff
  return false
end

def find_equivalences wff
  all_equivalences = ObjectSpace.each_object(Class).select{|cl| cl < Equivalence}
  all_equivalences = all_equivalences.select{|x| send (x.to_s.downcase + "?").to_sym, wff}
  return all_equivalences
end

def find_all_equivalences wff
  eqs = {}
  if wff.is_a? Variable
    return {}
  end
  unless wff.atom1.nil?
    eqs.merge! find_all_equivalences wff.atom1
  end
  unless wff.atom2.nil?
    eqs.merge! find_all_equivalences wff.atom2
  end
  eqs[wff] = find_equivalences wff
  return eqs
end

#puts "#{wff.to_s} can be turned into:"
#all_equivalences.each{|eq| n = eq.new wff; puts "#{n.to_s} : #{n.wff.to_s}"}

def resolve_ambiguities list_of_formulae, question_string
  if list_of_formulae.length > 1
    puts ("Choose element to #{question_string}:\n#{list_of_formulae.map.with_index{|x, i| i.to_s + ': ' + x.to_s}.join("\n")}").cyan
    selected = list_of_formulae[gets.chomp.to_i]
  else
    selected = list_of_formulae[0]
  end
end
