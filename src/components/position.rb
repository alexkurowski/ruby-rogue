Component.new :position,
  x: 0,
  y: 0


class Component::Position

  def + v
    Vector.new self.x + v.x, self.y + v.y
  end


  def - v
    Vector.new self.x - v.x, self.y - v.y
  end

end
