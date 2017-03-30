class Law
  class << self; attr_reader :available, :abbrev end

  def self.to_s
    return self.inspect
  end
end
