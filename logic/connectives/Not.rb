class Not < UnaryConnective

  attr_reader :symbol, :latex, :strings

  def initialize
    @symbol = "¬"
    @precedence = 1
    @latex = "\\neg "
    @strings = ["not", "¬"]
  end

end
