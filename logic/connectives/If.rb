class If < BinaryConnective

  attr_reader :symbol, :latex, :strings

  def initialize
    @precedence = 4
    @symbol = "→"
    @latex = "\\rightarrow"
    @strings = ["if", "->", "→"]
  end

end

