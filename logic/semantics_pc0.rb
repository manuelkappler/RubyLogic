class Interpretation

  def initialize predicates, constants
    @constants = constants

    @predicates = predicates

    @pi_hash = @predicates.map.with_object({}){|pred, hsh| hsh[pred] = Set.new}
    puts @pi_hash
  end

  def set_predicate predicate, boolean, constants
    begin
      raise LogicError if constants.any?{|x| puts "Checking if #{x} is among #{@constants}: #{@constants.include? x}"; not @constants.include? x}
      if boolean
        raise LogicError if constants.length != predicate.arity
        @pi_hash[predicate] << constants
      end
    rescue Exception => e
      puts "LogicError in set_predicate: #{e.backtrace}"
    end
  end


  def pi predicate, element
    return @pi_hash[predicate].include? element
  end

  def to_s
    return @pi_hash.map{|pred, ext| "π(#{pred}) = {#{ext.empty? ? "∅" : ext.map{|e| '('+ e.map{|d| 'δ(' + d.to_s + ')'}.join(',') + ')'}.join(',')}}"}
  end

  def to_latex
  end

end
