class Component::Creature

  attr_accessor :hp, :dead, :sight


  def initialize
    @hp    = 1
    @dead  = false
    @sight = 16
  end

end
