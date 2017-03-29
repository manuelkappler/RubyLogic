class Or < BinaryConnective

  attr_reader :strings, :symbol, :latex

  def initialize
    @symbol = "∨"
    @latex = "\\vee"
    @strings = ["or", "∨"]
    @precedence = 3
  end

end
