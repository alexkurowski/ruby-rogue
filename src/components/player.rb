class Component::Player

  attr_accessor :mode, :cursor


  def initialize
    @mode   = :normal
    @cursor = Vector.new
  end

end
