class Iff < BinaryConnective

  attr_reader :symbol, :latex, :strings

  def initialize
    @precedence = 5
    @symbol = "↔"
    @latex = "\\leftrightarrow"
    @strings = ["iff", "⇔", "↔", "<->"]
  end

end
