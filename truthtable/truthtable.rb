require 'terminal-table'
require 'colorize'

class TruthTableCreater

  attr_reader :tt

  def initialize string
    # Load syntax and semantics
     
    load File::expand_path('../logic/syntax_sentential.rb')
    load File::expand_path('../logic/semantics_sentential.rb')

    # Load helper functions: the ProofTree class which keeps track of the proof, and parse_string which turns strings into an Implication claim
     
    load File::expand_path('../proof/lib/ProofTree.rb')
    load File::expand_path('../proof/lib/parse_string_sentential.rb')

    # Load the implication helper class

    load File::expand_path('../logic/implication.rb')

    # Load DeMorgan equivalences (no other equivalence laws needed or used)

    load File::expand_path("../logic/laws/equivalences/Equivalence.rb")
    load File::expand_path("../logic/laws/equivalences/DeMorgan.rb")
    load File::expand_path("../logic/laws/equivalences/DoubleNegation.rb")

    # Load all Implication Laws for pc0

    load File::expand_path("../logic/laws/Law.rb")
    load File::expand_path("../logic/laws/BranchingLaw.rb")
    load File::expand_path("../logic/laws/Given.rb")
    load File::expand_path("../logic/laws/ConjunctionPremise.rb")
    load File::expand_path("../logic/laws/ConjunctionConclusion.rb")
    load File::expand_path("../logic/laws/DisjunctionPremise.rb")
    load File::expand_path("../logic/laws/DisjunctionConclusion.rb")
    load File::expand_path("../logic/laws/ConditionalPremise.rb")
    load File::expand_path("../logic/laws/ConditionalConclusion.rb")
    load File::expand_path("../logic/laws/BiconditionalPremise.rb")
    load File::expand_path("../logic/laws/BiconditionalConclusion.rb")
    load File::expand_path("../logic/laws/ContradictoryConclusion.rb")
    load File::expand_path("../logic/laws/SubstituteEquivalents.rb")

    @variables = string.scan(/[A-Z]{1}/).uniq.flatten.sort.map.with_object({}){|x, hsh| hsh[x] = AtomicSentence.new(x)}
    @tt = create_initial_hash 
    @formulas = string.split(',').map(&:strip).map{|element| parse_string_sentential element, @variables}
    @formulas.each{|x|
      add_sentence x
    }
  end

  def create_initial_hash 
    hash = {}
    @variables.each_with_index{|val, idx| hash[val[1]] = [true, false].repeated_permutation(@variables.length).to_a.map{|x| x[idx]}}
    puts hash
    return hash
  end

  # Adds a sentence to the table
  def add_sentence sentence
    if sentence.is_a? AtomicSentence
      puts "Sentence: #{sentence.inspect} is a atomic and should already be in tt: #{@tt[sentence]}"
      puts @tt
      return false
    elsif sentence.connective.is_a? UnaryConnective
      puts "Sentence is negated: #{sentence.to_s}. Adding #{sentence.element1.to_s} to @tt"
      add_sentence(sentence.element1)
      @tt[sentence] = @tt[sentence.element1].map{|x| evaluate sentence.connective, x}
    elsif sentence.connective.is_a? BinaryConnective
      puts "Sentence is composite. Element1 is #{sentence.element1.inspect} and Element2 is #{sentence.element2.inspect}"
      add_sentence(sentence.element1)
      add_sentence(sentence.element2)
      @tt[sentence] = @tt[sentence.element1].each_with_index.map{|x, idx| evaluate(sentence.connective, x, @tt[sentence.element2][idx])}
    end
  end
    

  def row_wise_ary
    header = (@variables.values | @formulas).map{|x| "\\[" + x.to_latex + "\\]"}
    rows = []
    0.upto(@tt.values[0].length - 1) do |row_index|
      rows << (@variables.values | @formulas).map{|x| val = @tt[x][row_index]; val ? "\\[ T \\]" : "\\[ F \\]"}
    end
    return {"header" => header, "rows" => rows}
  end

  def are_equivalent? wff1, wff2
    begin
      return @tt[wff1] == @tt[wff2]
    rescue
      raise KeyError
    end
  end
end
