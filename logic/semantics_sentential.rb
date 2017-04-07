class Interpretation

  def initialize impl, counterexample=false
    @sentences = {}
    if counterexample
      construct_counterexample impl
    end
  end

  def construct_counterexample impl
    raise LogicError if not impl.elementary?
    impl.premises.each do |prem|
      if prem.is_a? AtomicSentence
        @sentences[prem.to_s] = "T"
      else
        @sentences[prem.element1.to_s] = "F"
      end
    end
    if impl.conclusion.is_a? AtomicSentence and not impl.conclusion.is_a? Contradiction
      @sentences[impl.conclusion.to_s] = "F"
    elsif impl.conclusion.is_a? CompositeSentence
      @sentences[impl.conclusion.element1.to_s] = "T"
    end
  end

  def to_latex
    return '\\[' + @sentences.map{|key, value| "#{key} = #{value}"}.join(',') + '\\]'
  end
end
