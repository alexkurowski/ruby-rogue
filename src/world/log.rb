module Log

  def self.init
    @log = ['', '', '']
    @max = 100
  end


  def self.add message
    @log.push message
    @log.shift if @log.count > @max
  end


  def self.last count
    @log.last count
  end

end
