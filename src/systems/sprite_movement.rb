module System::SpriteMovement

  def self.run
    entities = Entities.filter_by_component :sprite

    entities.each do |entity|
      if entity.sprite.offset.x.abs > min_difference
        entity.sprite.offset.x *= drag
      end

      if entity.sprite.offset.y.abs > min_difference
        entity.sprite.offset.y *= drag
      end

      if entity.sprite.offset.x.abs <= min_difference
        entity.sprite.offset.x = 0
      end

      if entity.sprite.offset.y.abs <= min_difference
        entity.sprite.offset.y = 0
      end
    end
  end


  def self.min_difference
    0.1
  end


  def self.drag
    if Display.big?
    then 0
    else 0.9
    end
  end

end
