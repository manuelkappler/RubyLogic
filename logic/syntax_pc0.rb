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
end

class Connective
end

class Sentence
end

class AtomicSentence < Sentence
  def initialize predicate, constants
    @predicate = predicate
    if constants.length != predicate.arity
      puts "Constants are of length #{constants.length} but predicate has arity #{predicate.arity}"
      raise LogicError
    else
      @constants = constants
    end
  end
end

class CompositeSentence < Sentence
  def initialize connective, *sentences

  end
end

# Load all connectives

require_relative "connectives/Or"
require_relative "connectives/And"
require_relative "connectives/If"
require_relative "connectives/Iff"
require_relative "connectives/Not"
