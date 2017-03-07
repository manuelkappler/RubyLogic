class Atom
  def to_s
    return @symbol
  end
  def get_vars
    if self.is_a? Variable
      return self
    elsif self.is_unary?
      return self.atom1.get_vars
    else
      return [self.atom1.get_vars, self.atom2.get_vars]
    end
  end

  def is_equal? other_atom
    if self.class != other_atom.class
#      puts "Class mismatch #{self.inspect} #{other_atom.inspect}"
#      puts "#{self.class != other_atom.class}"
      return false
    elsif self.is_a? Variable or other_atom.is_a? Variable
#      puts "Two variables? #{self.inspect} #{other_atom.inspect}"
#      puts "#{self == other_atom}"
      return self == other_atom
    elsif self.is_unary? != other_atom.is_unary?
#      puts "Unary mismatch. #{self.inspect} #{other_atom.inspect}"
      return false
    elsif self.is_unary? and other_atom.is_unary?
#      puts "Two unaries compared. #{self.inspect} #{other_atom.inspect}"
#      puts "#{(self.connective.is_a? other_atom.connective.class and self.atom1.is_equal? other_atom.atom1)}"

      return (self.connective.is_a? other_atom.connective.class and self.atom1.is_equal? other_atom.atom1)
    else
#      puts "Recurse. #{self.inspect} #{other_atom.inspect}"
      return (self.atom1.is_equal? other_atom.atom1 and self.atom2.is_equal? other_atom.atom2 and self.connective.is_a? other_atom.connective.class)
    end
  end

end

class Connective
  include Comparable

  attr_reader(:precedence)

  def to_s
    return @symbol
  end

  def <=>(other_connective)
    raise ArgumentError unless other_connective.is_a? Connective
    if self.precedence < other_connective.precedence
      return 1
    elsif self.precedence > other_connective.precedence
      return -1
    else
      return 0
    end
  end
end

class UnaryConnective < Connective
end

class BinaryConnective < Connective

  def or_idempotence
    return false unless @connective.is_a? Or
    #(@t1.is_a? Variable and @t2.is_a? Variable and @t1.to_s == @t2.to_s) ? return true : 
    
  end

  def and_idempotence

  end

  def double_negation 

  end

  def distributivity 

  end

  def associativity

  end

end

class Variable < Atom
  def initialize(symbol)
    @symbol = symbol
  end

  def to_latex
    return @symbol.to_s
  end
end

class WFF < Atom

  attr_reader(:atom1, :atom2, :connective)

  def initialize(*args)
    if args.size == 2
      raise TypeError unless (args[1].is_a? UnaryConnective and args[0].is_a? Atom)
      @atom1 = args[0]
      @connective = args[1]
    elsif args.size == 3
      raise TypeError unless args[0].is_a? Atom and args[2].is_a? Atom and args[1].is_a? Connective
      @atom1 = args[0]
      @connective = args[1]
      @atom2 = args[2]
    else
      raise ArgumentError 
    end
  end

  def is_unary?
    return @atom2.nil?
  end

  def to_s
    if @atom1.is_a? Variable
      a1 = @atom1.to_s
    else
      a1 = "(#{@atom1.to_s})"
    end
    if is_unary?
      return "#{@connective.to_s}#{a1}"
    else
      if @atom2.is_a? Variable
        a2 = @atom2.to_s
      else
        a2 = "(#{@atom2.to_s})"
      end
      return "#{a1}#{@connective.to_s}#{a2}"
    end
  end

  def to_latex
    if @atom1.is_a? Variable
      a1 = @atom1
    else
      a1 = "(#{@atom1.to_latex})"
    end
    if is_unary?
      return "#{@connective.to_latex} #{a1}"
    else
      if @atom2.is_a? Variable
        a2 = @atom2
      else
        a2 = "(#{@atom2.to_latex})"
      end
      return "#{a1} #{@connective.to_latex} #{a2}"
    end

  end

  def eval(t1, t2=nil)
    if t2.nil? and @atom2.nil?
      return @connective.eval t1
    elsif (t2.nil? and not @atom2.nil?) or (@atom2.nil? and not t2.nil?)
      raise ArgumentError
    else
      return @connective.eval t1, t2
    end
  end

end

class And < BinaryConnective
  def initialize
    @precedence = 2
    @symbol = "∧"
  end

  def eval t1, t2
    if t1 and t2
      return true
    else
      return false
    end
  end
end

class Or < BinaryConnective
  def initialize
    @precedence = 3
    @symbol = "∨"
  end

  def eval t1, t2
    if t1 
      return true
    elsif t2
      return true
    else
      return false
    end
  end
end

class If < BinaryConnective
  def initialize
    @precedence = 4
    @symbol = "→"
  end

  def eval t1,t2
    if t1
      if t2
        return true
      else
        return false
      end
    else
      return true
    end
  end
end

class Iff < BinaryConnective
  def initialize
    @precedence = 5
    @symbol = "↔"
  end

  def eval t1, t2
    if t1
      if t2
        return true
      else
        return false
      end
    else
      if t2
        return false
      else
        return true
      end
    end
  end
end


class Not < UnaryConnective
  def initialize
    @symbol = "¬"
    @precedence = 1
  end

  def eval t1
    if t1
      return false
    else
      return true
    end
  end
end



# Dummy connective for parsing
class Sentinel < UnaryConnective
  def initialize
    @precedence = 10
  end
end

class LeftParen < UnaryConnective
  def initialize
    @precedence = 9
  end
end
