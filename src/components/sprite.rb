class Component::Sprite

  attr_accessor :char, :color, :offset


  def initialize
    @char   = ' '
    @color  = '#ffffffff'
    @offset = Vector.new
  end

end
