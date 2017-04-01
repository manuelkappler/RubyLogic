class Interpretation

  def initialize predicates, constants
    @constants = constants

    @predicates = predicates

    @pi_hash = @predicates.map.with_object({}){|pred, hsh| hsh[pred] = Set.new}
    puts @pi_hash
    @equalities = []
    @inequalities = []
    update_inequalities
    print @inequalities.map(&:to_s).join(",") + "\n"
  end

  def set_predicate predicate, boolean, constants
    begin
      constants.any?{|x| not @constants.include? x}
      if boolean
        @pi_hash[predicate] << constants
      end
    end
  end

  def add_equality eq
    @equalities << eq
    update_inequalities
  end

  def update_inequalities
    ineq = []
    @constants.each do |const1|
      @constants.each do |const2|
        if const1 == "" or const1.nil? or const2 == "" or const2.nil?
          next
        elsif const1 == const2
          # puts "Reflexivity"
          next
        elsif @equalities.any?{|x| (x.element1 == const1 and x.element2 == const2) or (x.element2 == const1 and x.element1 == const2)}
          # puts "This is an equality #{const1} = #{const2}"
          next
        elsif ineq.any?{|x| (x.element1 == const1 and x.element2 == const2) or (x.element2 == const1 and x.element1 == const2)}
          # puts "Skipping already present inequality: #{const1} != #{const2}"
          next
        else
          # puts "New inequality: #{const1} != #{const2}"
          ineq << Equality.new(const1, const2)
        end
      end
    end
    @inequalities = ineq
  end


  def pi predicate, element
    return @pi_hash[predicate].include? element
  end

  def to_s
    delta_string = @equalities.map{|x| "\\delta(#{x.element1}) = \\delta(#{x.element2})"}.join(", ") + "\\\\" + @inequalities.map{|x| "\\delta(#{x.element1}) \\neq \\delta(#{x.element2})"}.join(", ")
    pi_string = @pi_hash.map{|pred, ext| "π(#{pred}) = {#{ext.empty? ? "∅" : ext.map{|e| '('+ e.map{|d| 'δ(' + d.to_s + ')'}.join(',') + ')'}.join(',')}}"}.join("\n")
    return delta_string + "\n" + pi_string
  end

  def to_latex
    delta_string = @equalities.map{|x| a, b = [x.element1, x.element2].map(&:to_s).sort; "\\delta(#{a}) = \\delta(#{b})"}.join(", ") + "\\\\" + @inequalities.map{|x| a, b = [x.element1, x.element2].map(&:to_s).sort; "\\delta(#{a}) \\neq \\delta(#{b})"}.join(", ")
    pi_string = @pi_hash.map{|pred, ext| "\\pi(#{pred}) = #{ext.empty? ? "\\varnothing" : "\\{" + ext.map{|e| '('+ e.map{|d| '\\delta(' + d.to_s + ')'}.join(',') + ')'}.join(',')}\\}"}.join("\\\\")

    return "\\[" + delta_string + "\\\\" + pi_string + "\\]"
  end

end
