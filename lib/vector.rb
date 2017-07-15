class Vector < Struct.new :x, :y

  def initialize _x = 0, _y = 0
    self.x = _x
    self.y = _y
  end

  def + v; Vector.new self.x + v.x, self.y + v.y end
  def - v; Vector.new self.x - v.x, self.y - v.y end
  def * v; Vector.new self.x * v, self.y * v end
  def / v; Vector.new self.x / v, self.y / v end

  def length
    Math.sqrt self.x * self.x + self.y * self.y
  end

  def magnitude
    l = length
    Vector.new self.x / l, self.y / l
  end

end
