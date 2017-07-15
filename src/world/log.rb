module Log

  def self.init
    @log = Array.new 100 { '' }
  end


  def self.add message
    @log.push message
    @log.shift
  end


  def self.last count
    @log.last count
  end

end
