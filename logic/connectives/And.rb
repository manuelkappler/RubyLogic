class And < BinaryConnective

  attr_reader :latex, :strings, :symbol

  def initialize
    @precedence = 2
    @symbol = "∧"
    @strings = ["and", "∧"]
    @latex = "\\wedge "
  end

end
