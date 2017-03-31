def parse_string_pc0 input_string, constants_hsh, predicates_hsh
  puts input_string
  return Contradiction.new if input_string == "⊥" or input_string == "Contradiction"
  eq_match = /(?<a>[a-z])\s?(≈|eq)\s?(?<b>[a-z])/.match(input_string)
  unless eq_match.nil?
    return Equality.new(constants_hsh[eq_match[:a]], constants_hsh[eq_match[:b]])
  end
  #puts constants_hsh
  #puts predicates_hsh
  neg, disj, conj, cond, bicond, paren, eq = [Not.new, Or.new, And.new, If.new, Iff.new, LeftParenthesis.new]
  operators = {"not" => neg, "¬" => neg, "or" => disj, "∨" => disj, "∧" => conj, "and" => conj, "->" => cond, "<->" => bicond, "→" => cond, "↔" => bicond, "(" => paren, "≈" => eq, "eq" => eq} 
  premise_queue = OutputQueue.new
  operator_stack = [Sentinel.new]
  input_string.split(/\s*(and|or|->|<->|∧|∨|→|↔|¬|not|(?<![a-z])\)|\((?=\s?[A-Z]))\s*/).each do |element|
    #print "Current operator stack: #{operator_stack.map(&:to_s)}\n"
    #print "Current premise queue: #{premise_queue.map(&:to_s)}\n"
    #print "Working on: #{element}\n"
    if element == ")"
      until operator_stack[-1].is_a? LeftParenthesis or operator_stack[-1].is_a? Sentinel
        premise_queue << operator_stack.pop
      end
      operator_stack.pop
    elsif ["and","or","->", "<->","∧","∨", "→", "↔"].include? element or ["not", "¬"].include? element
#      puts "Will compare #{operator_stack[-1].inspect} with #{operators[element].inspect}" unless operator_stack[-1].is_a? Sentinel
      while (not operator_stack[-1].is_a? Sentinel) and operator_stack[-1] > operators[element]
#        puts "Popping to queue from operator_stack"
        premise_queue << operator_stack.pop
      end
#      puts "Adding #{operators[element]} to stack"
      operator_stack << operators[element]
    elsif element == "("
      operator_stack << operators[element]
    elsif element == ""
    else
      pred = predicates_hsh[element[0]]
      vars = element.scan(/.*?([a-z]{1}).*?/).flatten.map{|x| constants_hsh[x]}
      #puts "Predicate: #{pred.to_s}(#{vars.map(&:to_s).join(',')})"
      premise_queue << AtomicSentence.new(pred, vars)
    end
#    print "Done.\n Current premise queue: #{premise_queue.map(&:to_s)}\n Current operator stack: #{operator_stack.map(&:to_s)}\n\n\n"
  end
#  puts "Done parsing all elements, putting things together"
  until operator_stack[-1].is_a? Sentinel
    x = operator_stack.pop
    if x.is_a? LeftParenthesis
      raise MismatchedParenthesis
    else
      premise_queue << x
    end
  end
  return premise_queue.get_wff
end

class OutputQueue < Array

  def get_wff
    #puts self.map(&:to_s)
    if self[-1].is_a? BinaryConnective
      op = self.pop
      a2 = self.get_wff
      a1 = self.get_wff
      return CompositeSentence.new(op, a1, a2)
#      return WFF.new(self.get_wff, op, self.get_wff)
    elsif self[-1].is_a? UnaryConnective and not self[-1].is_a? EqualityDummy
      op = self.pop
      return CompositeSentence.new(op, self.get_wff)
    else
      return self.pop
    end
  end

end

class Sentinel < UnaryConnective
  def initialize
    @precedence = 10
  end
  def to_s
    return "S"
  end
end

class EqualityDummy < UnaryConnective
  def initialize
    @precedence = 0
  end
  def to_s
    return "≈"
  end
end

class LeftParenthesis < UnaryConnective
  def initialize
    @precedence = 9
  end
  def to_s
    return "("
  end
end
