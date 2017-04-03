class Given < Law
  @available = false

  def apply state, wff=nil
    return state
  end
  def to_s
    return "Given"
  end
  def self.to_latex
    return "(Given)"
  end
  def to_latex
    return "(Given)"
  end
end
