require_relative 'Connectives'
require_relative 'Logic'

# Takes strings such as "not A -> ( B and not ( C or not A ) )"
# and turns them into a TruthTable containing various WFFs
 
# This code implements a shunting yard algorithm for parsing. See for example: www.engr.mun.ca/~theo/Misc/exp_parsing.htm and en.wikipedia.org/wiki/Shunting-yard-algorithm
 
def parse_string string, variables={}, verbose=false, novars=false
  s = string.dup
  recounter = 0
  while /\(\S|\S\)/.match(s)
    s.gsub!(/([()])([A-Zn(]{1})/, "\\1 \\2")
    s.gsub!(/([A-Zt)]{1})([()])/, "\\1 \\2")
    if (recounter += 1) >= 5
      puts "Can't parse in less than 5 steps. Try entering the formula with spaces between parentheses"
      raise ArgumentError
    end
  end
  operators = {"not" => Not.new(), "or" => Or.new(), "and" => And.new(), "->" => If.new(), "<->" => Iff.new(), "(" => LeftParen.new()}
  sentinel = Sentinel.new
  output_queue = OutputQueue.new()
  operator_stack = [sentinel]
#  wff_stack = []
#  vars = []
  elements = s.split
  elements.each do |e|
    if ("A".."Z").include? e
      variables[e] = Variable.new(e) unless variables.has_key? e
      output_queue << variables[e]
#      print "Vars after adding #{e}: \t" + output_queue.to_s + "\n"
    elsif ["not", "and", "or", "->", "<->"].include? e
      while (not operator_stack[-1].is_a? Sentinel) and operator_stack[-1] > operators[e]
          output_queue << operator_stack.pop
      end
      operator_stack << operators[e]
#      print "OP after adding #{e}: \t" + operator_stack.to_s + "\n"
    elsif e == "("
      operator_stack << operators[e]
    elsif e == ")"
      until operator_stack[-1].is_a? LeftParen or operator_stack[-1].is_a? Sentinel
        output_queue << operator_stack.pop
      end
#      print "After paren"
      operator_stack.pop
#      print operator_stack.to_s + "\n"
    else
      raise ArgumentError
    end
  end
#  print operator_stack
#  print output_queue
  until operator_stack[-1].is_a? Sentinel
    x = operator_stack.pop
    if x.is_a? LeftParen
      raise MismatchedParenthesis
    else
      output_queue << x
    end
  end

#  print "\n" + output_queue.map{|x| x.to_s}.join("\t") + "\n"

  return variables, output_queue.get_wff unless novars
  return output_queue.get_wff if novars

end

class OutputQueue < Array

  def get_wff
    if self[-1].is_a? BinaryConnective
      op = self.pop
      a2 = self.get_wff
      a1 = self.get_wff
      return WFF.new(a1, op, a2)
#      return WFF.new(self.get_wff, op, self.get_wff)
    elsif self[-1].is_a? UnaryConnective
      op = self.pop
      return WFF.new(self.get_wff, op)
    else
      return self.pop
    end
  end

end

class MismatchedParenthesis < StandardError
end
