module Log

  def self.init
    @log  = Array.new 100 { '' }
    @last = ''
  end


  def self.add message
    @last << message << ' '
  end


  def self.submit
    return if @last == ''

    @log.shift
    @log.push @last
    @last = ''
  end


  def self.last count
    @log.last count
  end

end
