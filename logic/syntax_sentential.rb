class Constant

  def initialize name
    @name = name
    @abbrev = name[0].downcase
  end

end

class Predicate
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

# Load all connectives
# 
require_relative "connectives/UnaryConnective"
require_relative "connectives/BinaryConnective"
require_relative "connectives/Connective"
require_relative "connectives/Or"
require_relative "connectives/And"
require_relative "connectives/If"
require_relative "connectives/Iff"
require_relative "connectives/Not"

