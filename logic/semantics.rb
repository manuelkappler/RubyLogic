class Model


  def initialize
    @domain = Set.new

    @delta_hash = {}

    @pi_hash = {}
  end

  def new_predicate predicate, extension
    @pi_hash[predicate] = extension
  end

  def add_to_domain element

  end

  def map_to_domain constant, element

  end

  def is_in_domain? element
  end

  def pi predicate, element
  end

  

end

class Extension
  
  def initialize predicate, elements
    @predicate = predicate
    @elements = elements
  end

end

