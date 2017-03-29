class Constant

  def initialize string
    if string.length == 1
      @name = string
      @abbrev = string
    else
      @name = string
      @abbrev = string[0].downcase
    end
  end

  def to_s
    return @name
  end

end

class Predicate

  attr_reader :name, :arity

  def initialize name, arity

    @name = name
    @arity = arity

  end

  def is_valid_extension? args
    return *args.length == @arity
  end

  def to_s
    return @name
  end
end

class Equality < Predicate
  def initialize
    @name = "≈"
    @arity = 2
  end
end

class Connective
end

class Sentence
  def is_equal? other_atom
    if self.class != other_atom.class
      return false
    elsif self.is_a? AtomicSentence or other_atom.is_a? AtomicSentence
      return (self.predicate == other_atom.predicate and self.constants.map.with_index{|x, idx| true if other_atom.constants[idx] == x}.all?)
    elsif (self.is_a? CompositeSentence) != (other_atom.is_a? CompositeSentence)
      return false
    elsif (self.is_a? CompositeSentence) and (other_atom.is_a? CompositeSentence)
      return (self.connective.is_a? other_atom.connective.class and self.element1.is_equal? other_atom.element1)
    else
      return (self.element1.is_equal? other_atom.element1 and self.element2.is_equal? other_atom.element2 and self.connective.is_a? other_atom.connective.class)
    end
  end

  def get_applicable_laws premise=true
    return ObjectSpace.each_object(Class).select{|cl| cl < Law and cl.available}.select{|law| law.applies? self, premise}
  end

  def <=> other_atom
    return 0 if self.is_equal? other_atom
    return 1 if other_atom.to_s <= self.to_s
    return -1 
  end
end

class AtomicSentence < Sentence
  attr_reader :predicate, :constants
  def initialize predicate, constants
    @predicate = predicate
    if constants.length != predicate.arity
      puts "Constants are of length #{constants.length} but predicate has arity #{predicate.arity}"
      raise LogicError
    else
      @constants = constants
    end
  end

  def to_s
    return "#{@predicate}(#{@constants.map(&:to_s).join(", ")})"
  end

  def to_latex
    return "#{@predicate}(#{@constants.map(&:to_s).join(",")})"
  end

end

class Contradiction < Sentence

  def initialize
    @symbol = "⊥"
  end

  def to_latex
    return "\\bot"
  end

  def to_s
    return "⊥"
  end

end

class CompositeSentence < Sentence

  attr_reader :connective, :element1, :element2

  def initialize connective, *sentences
    if connective.is_a? BinaryConnective
      @element1 = sentences[0]
      @element2 = sentences[1]
      @connective = connective
    elsif connective.is_a? UnaryConnective
      @element1 = sentences[0]
      @connective = connective
      @element2 = nil
    end
  end

  def to_s
    output(Proc.new{|x| x.to_s})
  end

  def to_latex
    output(Proc.new{|x| x.to_latex})
  end

  def output(procedure)
    if @connective.is_a? BinaryConnective
      if @element1.is_a? CompositeSentence and not @element1.connective.is_a? UnaryConnective
        el1 = "(#{procedure.call(@element1)})"
      else
        el1 = procedure.call(@element1)
      end
      if @element2.is_a? CompositeSentence and not @element2.connective.is_a? UnaryConnective
        el2 = "(#{procedure.call(@element2)})"
      else
        el2 = procedure.call(@element2)
      end
      return "#{el1} #{procedure.call(@connective)} #{el2}"
    else
      if @element1.is_a? CompositeSentence and not @element1.connective.is_a? UnaryConnective
        return "#{procedure.call(@connective)}(#{procedure.call(@element1)})"
      else
        return "#{procedure.call(@connective)}#{procedure.call(@element1)}"
      end
    end
  end


end

# Load all connectives

require_relative "connectives/UnaryConnective"
require_relative "connectives/BinaryConnective"
require_relative "connectives/Connective"
require_relative "connectives/Or"
require_relative "connectives/And"
require_relative "connectives/If"
require_relative "connectives/Iff"
require_relative "connectives/Not"

